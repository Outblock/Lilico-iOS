//
//  WalletManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Combine
import Flow
import Foundation
import KeychainAccess
import WalletCore

// MARK: - Define

extension WalletManager {
    static let flowPath = "m/44'/539'/0'/0/0"
    static let mnemonicStrength: Int32 = 128
    private static let defaultBundleID = "io.outblock.lilico"
    private static let mnemonicStoreKeyPrefix = "lilico.mnemonic"
    private static let mnemonicPwdStoreKey = "lilico.mnemonic.password"
    private static let walletFetchInterval: TimeInterval = 20
}

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var walletInfo: UserWalletResponse?
    @Published var supportedCoins: [TokenModel]?
    @Published var activatedCoins: [TokenModel] = []
    @Published var coinBalances: [String: Double] = [:]

    private var hdWallet: HDWallet?

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
        return hdWallet?.mnemonic
    }

    func getCurrentFlowAccountKey() -> Flow.AccountKey? {
        return hdWallet?.flowAccountKey
    }
    
    func getPrimaryWalletAddress() -> String? {
        return walletInfo?.primaryWalletModel?.getAddress
    }
    
    func isTokenActivated(symbol: String) -> Bool {
        for token in activatedCoins {
            if token.symbol == symbol {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Setter

extension WalletManager {
    #warning("change saving key from username to uid")
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
    func createHDWallet(mnemonic: String? = nil, passphrase: String = "") -> HDWallet? {
        if let mnemonic = mnemonic {
            return HDWallet(mnemonic: mnemonic, passphrase: passphrase)
        }

        return HDWallet(strength: WalletManager.mnemonicStrength, passphrase: passphrase)
    }

    func storeAndActiveMnemonicToKeychain(_ mnemonic: String, uid: String) throws {
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

        try set(toMainKeychain: encodedData, forKey: getMnemonicStoreKey(uid: uid), comment: "Lilico user uid: \(uid)")
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
        if !UserManager.shared.isAnonymous, let uid = UserManager.shared.getUid() {
            if !restoreMnemonicFromKeychain(uid: uid) {
                HUD.error(title: "no_private_key".localized)
            }
        }
    }

    private func restoreMnemonicFromKeychain(uid: String) -> Bool {
        if var encryptedData = getEncryptedMnemonicData(uid: uid),
           var pwd = getMnemoicPwd(),
           var decryptedData = try? WalletManager.decryptionAES(key: pwd, data: encryptedData),
           var mnemonic = String(data: decryptedData, encoding: .utf8)
        {
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
        guard let model = createHDWallet(mnemonic: mnemonic) else {
            return false
        }

        hdWallet = model
        return true
    }
}

// MARK: - Internal Getter

extension WalletManager {
    private func getMnemonicStoreKey(uid: String) -> String {
        return "\(WalletManager.mnemonicStoreKeyPrefix).\(uid)"
    }

    private func getEncryptedMnemonicData(uid: String) -> Data? {
        return getData(fromMainKeychain: getMnemonicStoreKey(uid: uid))
    }

    private func getMnemoicPwd() -> String? {
        return getString(fromMainKeychain: WalletManager.mnemonicPwdStoreKey)
    }
}

// MARK: - Coins

extension WalletManager {
    func fetchWalletDatas() async throws {
        try await fetchSupportedCoins()
        try await fetchActivatedCoins()
        try await fetchBalance()
    }

    private func fetchSupportedCoins() async throws {
        let coins: [TokenModel] = try await FirebaseConfig.flowCoins.fetch()
        let validCoins = coins.filter { $0.getAddress()?.isEmpty == false }
        supportedCoins = validCoins
    }

    private func fetchActivatedCoins() async throws {
        guard let supportedCoins = supportedCoins, supportedCoins.count != 0 else {
            activatedCoins.removeAll()
            return
        }

        guard let address = walletInfo?.primaryWalletModel?.getAddress, !address.isEmpty else {
            activatedCoins.removeAll()
            return
        }

        let enabledList = try await FlowNetwork.checkTokensEnable(address: Flow.Address(hex: address), tokens: supportedCoins)
        if enabledList.count != supportedCoins.count {
            throw WalletError.fetchFailed
        }

        var list = [TokenModel]()
        for (index, value) in enabledList.enumerated() {
            if value == true {
                list.append(supportedCoins[index])
            }
        }

        activatedCoins = list
    }

    private func fetchBalance() async throws {
        guard activatedCoins.count > 0 else {
            return
        }

        guard let address = walletInfo?.primaryWalletModel?.getAddress, !address.isEmpty else {
            throw WalletError.fetchBalanceFailed
        }

        let balanceList = try await FlowNetwork.fetchBalance(at: Flow.Address(hex: address), with: activatedCoins)
        if activatedCoins.count != balanceList.count {
            throw WalletError.fetchBalanceFailed
        }

        var newBalanceMap: [String: Double] = [:]

        for (index, value) in activatedCoins.enumerated() {
            let balance = balanceList[index]

            guard let symbol = value.symbol else {
                continue
            }

            newBalanceMap[symbol] = balance
        }

        coinBalances = newBalanceMap
    }
    
    /// get balance from cache then refresh from server
    func getBalance(by token: TokenModel) -> Double? {
        guard let symbol = token.symbol else {
            return nil
        }
        
        Task {
            try? await fetchBalance()
        }
        
        return coinBalances[symbol]
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

extension WalletManager: FlowSigner {
    public var address: Flow.Address {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return Flow.Address(hex: "")
        }
        return Flow.Address(hex: address)
    }
    
    public var hashAlgo: Flow.HashAlgorithm {
        // TODO: FIX ME, make it dynamic
        .SHA2_256
    }
    
    public var signatureAlgo: Flow.SignatureAlgorithm {
        // TODO: FIX ME, make it dynamic
        .ECDSA_SECP256k1
    }
    
    public var keyIndex: Int {
        // TODO: FIX ME, make it dynamic
        0
    }
    
    public func sign(signableData: Data) async throws -> Data {
        guard let hdWallet = hdWallet else {
            throw LLError.emptyWallet
        }
        
        let privateKey = hdWallet.getCurveKey(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        let hashedData = Hash.sha256(data: signableData)
        
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            throw LLError.signFailed
        }
        signature.removeLast()
        return signature
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
