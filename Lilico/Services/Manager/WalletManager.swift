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


// MARK: - Define

extension WalletManager {
    static let flowPath = "m/44'/539'/0'/0/0"
    static let mnemonicStrength: Int32 = 128
    static private let defaultBundleID = "io.outblock.lilico"
    static private let mnemonicStoreKeyPrefix = "lilico.mnemonic"
    static private let mnemonicPwdStoreKey = "lilico.mnemonic.password"
}

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var hasWallet: Bool = false

    #warning("已登录用户wallet的初始化")
    private var wallet: HDWallet? {
        didSet {
            hasWallet = wallet != nil
        }
    }
    
    private var mainKeychain = Keychain(service: Bundle.main.bundleIdentifier ?? defaultBundleID)
        .label("Lilico app backup")
        .synchronizable(true)
        .accessibility(.whenUnlocked)
    private let backupKeychain = Keychain(server: "https://lilico.app", protocolType: .https)

    init() {
        generateMnemonicPwdIfNeeded()
        restoreMnemonicForCurrentUser()
    }
}

// MARK: - Getter

extension WalletManager {
    func getMnemoic() -> String? {
        return wallet?.mnemonic
    }
    
    func getFlowAccountKey() -> Flow.AccountKey? {
        return wallet?.flowAccountKey
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
    func asyncCreateWalletAddressFromServer() {
        Task {
            let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.User.userAddress)
        }
    }
    
    func fetchWalletInfo() async {
        #warning("ServerWalletModel的获取")
        do {
            let response: UserWalletResponse = try await Network.request(LilicoAPI.User.userWallet)
            print(response)
        } catch {
            debugPrint(error)
        }
    }
}

// MARK: - Mnemonic

extension WalletManager {
    func createMnemonicModel(mnemonic: String? = nil, passphrase: String = "", forceCreate: Bool = false) throws -> Bool {
        // If there is already a wallet, we don't create a new wallet to replace current one
        if hasWallet, !forceCreate {
            HUD.debugError(title: "Already have a wallet !")
            return false
        }

        if let phrase = mnemonic {
            wallet = HDWallet(mnemonic: phrase, passphrase: passphrase)
        } else {
            wallet = HDWallet(strength: WalletManager.mnemonicStrength, passphrase: passphrase)
        }
        return true
    }
    
    func storeMnemonicToKeychain(username: String) throws {
        guard var password = getMnemoicPwd() else {
            throw LLError.emptyEncryptKey
        }

        guard var mnemonic = getMnemoic(), var data = mnemonic.data(using: .utf8) else {
            throw LLError.createWalletFailed
        }

        defer {
            password = ""
            mnemonic = ""
            data = Data()
        }

        var encodedData = try WalletManager.encryptionAES(key: password, data: data)
        defer {
            encodedData = Data()
        }
        
        try set(toMainKeychain: encodedData, forKey: getMnemonicStoreKey(username: username), comment: "Lilico user: \(username)")
    }
    
    @discardableResult
    func restoreMnemonicFromKeychain(username: String) -> Bool {
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
            
            wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
            return true
        }
        
        return false
    }
    
    private func generateMnemonicPwdIfNeeded() {
        if getMnemoicPwd() == nil {
            try? set(toMainKeychain: UUID().uuidString, forKey: WalletManager.mnemonicPwdStoreKey)
        }
    }
    
    private func restoreMnemonicForCurrentUser() {
        if !UserManager.shared.isAnonymous, let username = UserManager.shared.userInfo?.username {
            if !restoreMnemonicFromKeychain(username: username) {
                HUD.error(title: "Private key is missing !!")
            }
        }
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
