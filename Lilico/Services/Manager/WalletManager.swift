//
//  WalletManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Flow
import Foundation
import KeychainAccess
import WalletCore
import Combine

// MARK: - Define

extension WalletManager {
    static let flowPath = "m/44'/539'/0'/0/0"
    static let mnemonicStrength: Int32 = 128
    static private let defaultBundleID = "io.outblock.lilico"
    static private let mnemonicStoreKeyPrefix = "lilico.mnemonic"
    static private let mnemonicPwdStoreKey = "lilico.mnemonic.password"
    static private let walletFetchInterval: TimeInterval = 20
}

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var walletInfo: UserWalletResponse?

    private var mnemonicModel: HDWallet?
    
    private var mainKeychain = Keychain(service: Bundle.main.bundleIdentifier ?? defaultBundleID)
        .label("Lilico app backup")
        .synchronizable(true)
        .accessibility(.whenUnlocked)
    private let backupKeychain = Keychain(server: "https://lilico.app", protocolType: .https)
    
    private var walletInfoRetryTimer: Timer?
    private var cancellableSet = Set<AnyCancellable>()

    init() {
        generateMnemonicPwdIfNeeded()
        
        if UserManager.shared.isLoggedIn {
            restoreMnemonicForCurrentUser()
        }
        
        UserManager.shared.$isLoggedIn.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.reloadWalletInfo()
            }
        }.store(in: &cancellableSet)
    }
}

// MARK: - Getter

extension WalletManager {
    func getCurrentMnemoic() -> String? {
        return mnemonicModel?.mnemonic
    }
    
    func getCurrentFlowAccountKey() -> Flow.AccountKey? {
        return mnemonicModel?.flowAccountKey
    }
}

// MARK: - Setter

extension WalletManager {
    func setSecurePassword(_ pwd: String, username: String) throws {
        try set(toBackupKeychain: pwd, forKey: username)
    }
}

// MARK: - Server Wallet

extension WalletManager {
    
    /// Request server create wallet address, DO NOT call it multiple times.
    func asyncCreateWalletAddressFromServer() {
        Task {
            let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.User.userAddress)
        }
    }
    
    private func startWalletInfoRetryTimer() {
        debugPrint("WalletManager -> startWalletInfoRetryTimer")
        stopWalletInfoRetryTimer()
        let timer = Timer.scheduledTimer(timeInterval: WalletManager.walletFetchInterval, target: self, selector: #selector(onWalletInfoRetryTimer), userInfo: nil, repeats: false)
        walletInfoRetryTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func stopWalletInfoRetryTimer() {
        if let timer = walletInfoRetryTimer {
            timer.invalidate()
            walletInfoRetryTimer = nil
        }
    }
    
    @objc private func onWalletInfoRetryTimer() {
        debugPrint("WalletManager -> onWalletInfoRetryTimer")
        reloadWalletInfo()
    }
    
    func reloadWalletInfo() {
        debugPrint("WalletManager -> reloadWalletInfo")
        stopWalletInfoRetryTimer()
        
        if !UserManager.shared.isLoggedIn {
            return
        }
        
        Task {
            do {
                let response: UserWalletResponse = try await Network.request(LilicoAPI.User.userWallet)
                DispatchQueue.main.async {
                    self.walletInfo = response
                    self.pollingWalletInfoIfNeeded()
                    debugPrint(response)
                }
            } catch {
                DispatchQueue.main.async {
                    debugPrint(error)
                    self.startWalletInfoRetryTimer()
                }
            }
        }
    }
    
    /// polling wallet info, if wallet address is not exists
    private func pollingWalletInfoIfNeeded() {
        debugPrint("WalletManager -> pollingWalletInfoIfNeeded, isMainThread: \(Thread.isMainThread)")
        let isEmptyBlockChain = walletInfo?.primaryWalletModel?.isEmptyBlockChain ?? true
        if isEmptyBlockChain {
            startWalletInfoRetryTimer()
        }
    }
}

// MARK: - Mnemonic Create & Save

extension WalletManager {
    func createMnemonicModel(mnemonic: String? = nil, passphrase: String = "") -> HDWallet? {
        if let mnemonic = mnemonic {
            return HDWallet(mnemonic: mnemonic, passphrase: passphrase)
        }
        
        return HDWallet(strength: WalletManager.mnemonicStrength, passphrase: passphrase)
    }
    
    func storeAndActiveMnemonicToKeychain(_ mnemonic: String, username: String) throws {
        guard var password = getMnemoicPwd() else {
            throw LLError.emptyEncryptKey
        }

        guard var data = mnemonic.data(using: .utf8) else {
            throw LLError.createWalletFailed
        }

        defer {
            password = ""
            data = Data()
        }

        var encodedData = try WalletManager.encryptionAES(key: password, data: data)
        defer {
            encodedData = Data()
        }
        
        try set(toMainKeychain: encodedData, forKey: getMnemonicStoreKey(username: username), comment: "Lilico user: \(username)")
        if !activeMnemonic(mnemonic) {
            throw LLError.createWalletFailed
        }
    }
    
    private func generateMnemonicPwdIfNeeded() {
        if getMnemoicPwd() == nil {
            try? set(toMainKeychain: UUID().uuidString, forKey: WalletManager.mnemonicPwdStoreKey)
        }
    }
}

// MARK: - Mnemonic Restore

extension WalletManager {
    private func restoreMnemonicForCurrentUser() {
        if !UserManager.shared.isAnonymous, let username = UserManager.shared.userInfo?.username {
            if !restoreMnemonicFromKeychain(username: username) {
                HUD.error(title: "Private key is missing !!")
            }
        }
    }
    
    private func restoreMnemonicFromKeychain(username: String) -> Bool {
        if var encryptedData = getEncryptedMnemonicData(username: username),
           var pwd = getMnemoicPwd(),
           var decryptedData = try? WalletManager.decryptionAES(key: pwd, data: encryptedData),
           var mnemonic = String(data: decryptedData, encoding: .utf8) {
            defer {
                encryptedData = Data()
                pwd = ""
                decryptedData = Data()
                mnemonic = ""
            }
            
            return activeMnemonic(mnemonic)
        }
        
        return false
    }
    
    private func activeMnemonic(_ mnemonic: String) -> Bool {
        guard let model = createMnemonicModel(mnemonic: mnemonic) else {
            return false
        }
        
        mnemonicModel = model
        return true
    }
}

// MARK: - Internal Getter

extension WalletManager {
    private func getMnemonicStoreKey(username: String) -> String {
        return "\(WalletManager.mnemonicStoreKeyPrefix).\(username)"
    }
    
    private func getEncryptedMnemonicData(username: String) -> Data? {
        return getData(fromMainKeychain: getMnemonicStoreKey(username: username))
    }
    
    private func getMnemoicPwd() -> String? {
        return getString(fromMainKeychain: WalletManager.mnemonicPwdStoreKey)
    }
}

// MARK: - Helper

extension WalletManager {
    private func set(toBackupKeychain value: String, forKey key: String) throws {
        try backupKeychain.set(value, key: key)
    }
    
    private func getString(fromBackupKeychain key: String) -> String? {
        return try? backupKeychain.get(key)
    }
    
    // MARK: -
    
    private func set(toMainKeychain value: String, forKey key: String) throws {
        try mainKeychain.set(value, key: key)
    }
    
    private func set(toMainKeychain value: Data, forKey key: String, comment: String? = nil) throws {
        if let comment = comment {
            try mainKeychain.comment(comment).set(value, key: key)
        } else {
            try mainKeychain.set(value, key: key)
        }
    }
    
    private func getString(fromMainKeychain key: String) -> String? {
        return try? mainKeychain.getString(key)
    }
    
    private func getData(fromMainKeychain key: String) -> Data? {
        return try? mainKeychain.getData(key)
    }
    
    static func encryptionAES(key: String, iv: String = "0102030405060708", data: Data) throws -> Data {
        guard var keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            throw LLError.aesKeyEncryptionFailed
        }
        if keyData.count > 16 {
            keyData = keyData.prefix(16)
        } else {
            keyData = keyData.paddingZeroRight(blockSize: 16)
        }

        guard let encrypted = AES.encryptCBC(key: keyData, data: data, iv: ivData, mode: .pkcs7) else {
            throw LLError.aesEncryptionFailed
        }
        return encrypted
    }

    static func decryptionAES(key: String, iv: String = "0102030405060708", data: Data) throws -> Data {
        guard var keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            throw LLError.aesKeyEncryptionFailed
        }

        if keyData.count > 16 {
            keyData = keyData.prefix(16)
        } else {
            keyData = keyData.paddingZeroRight(blockSize: 16)
        }

        guard let decrypted = AES.decryptCBC(key: keyData, data: data, iv: ivData, mode: .pkcs7) else {
            throw LLError.aesEncryptionFailed
        }
        return decrypted
    }
}

extension HDWallet {
    func getPublicKey() -> String {
        let p256PublicKey = getCurveKey(curve: .secp256k1, derivationPath: WalletManager.flowPath)
            .getPublicKeySecp256k1(compressed: false)
            .uncompressed
            .data
            .hexValue
            .dropPrefix("04")
        return p256PublicKey
    }
    
    func sign(_ text: String) -> String? {
        guard let textData = text.data(using: .utf8) else {
            return nil
        }
        
        let data = Flow.DomainTag.user.normalize + textData
        return sign(data)
    }
    
    func sign(_ data: Data) -> String? {
        let privateKey = getCurveKey(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        let hashedData = Hash.sha256(data: data)
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            return nil
        }
        
        signature.removeLast()
        return signature.hexValue
    }
    
    var flowAccountKey: Flow.AccountKey {
        let p256PublicKey = getCurveKey(curve: .secp256k1, derivationPath: WalletManager.flowPath)
            .getPublicKeySecp256k1(compressed: false)
            .uncompressed
            .data
            .hexValue
            .dropPrefix("04")
        let key = Flow.PublicKey(hex: String(p256PublicKey))
        return Flow.AccountKey(publicKey: key,
                               signAlgo: .ECDSA_SECP256k1,
                               hashAlgo: .SHA2_256,
                               weight: 1000)
    }
    
    var flowAccountP256Key: Flow.AccountKey {
        let p256PublicKey = getCurveKey(curve: .nist256p1, derivationPath: WalletManager.flowPath)
            .getPublicKeyNist256p1()
            .uncompressed
            .data
            .hexValue
            .dropPrefix("04")
        let key = Flow.PublicKey(hex: String(p256PublicKey))
        return Flow.AccountKey(publicKey: key,
                               signAlgo: .ECDSA_P256,
                               hashAlgo: .SHA2_256,
                               weight: 1000)
    }
}

extension Flow.AccountKey {
    func toCodableModel() -> AccountKey {
        return AccountKey(hashAlgo: hashAlgo.index,
                          publicKey: publicKey.hex,
                          sign_algo: signAlgo.index,
                          weight: weight)
    }
}

extension String {
    func dropPrefix(_ prefix: String) -> Self {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}
