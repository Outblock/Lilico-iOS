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

enum LLError: Error {
    case createWalletFailed
    case aesKeyEncryptionFailed
    case aesEncryptionFailed
    case missingUserInfoWhilBackup
    case emptyiCloudBackup
    case alreadyHaveWallet
    case emptyWallet
    case decryptBackupFailed
    case incorrectPhrase
    case emptyEncryptKey
}

class WalletManager: ObservableObject {
    static let flowPath = "m/44'/539'/0'/0/0"

    static let shared = WalletManager()

    private let storeKey = "lilico.mnemonic"
    private let passwordKey = "lilico.mnemonic.password"
    static let encryptionKey = "4047b6b927bcff0c"

    var hasWallet: Bool {
        return wallet != nil
    }

    var wallet: HDWallet?

    let mnemonicStrength: Int32 = 128
    let mnemonicStringStrength: Int32 = 256

    enum MnemonicStrength: Int {
        case length12 = 128
        case length24 = 256
    }

    private var accessGroup = "Wallet"
    private var defaultBundleID = "io.outblock.lilico"
    let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "defaultBundleID")
        .label("Lilico app backup")
        .synchronizable(true)
        .accessibility(.whenUnlocked)

    let backupKeychain = Keychain(server: "https://lilico.app", protocolType: .https)

    let passwordKeychain = Keychain(service: Bundle.main.bundleIdentifier ?? "defaultBundleID")
        .label("Lilico password")
        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: [.biometryAny])

    init() {
        let password = try? keychain.get(passwordKey)
        if password == nil {
            // First time, if passwordKey is empty, generate one
            try? keychain.set(UUID().uuidString, key: passwordKey)
        }

        if !UserManager.shared.isAnonymous,
           let username = UserManager.shared.userInfo?.username
        {
            if !restoreWalletFromKeychain(username: username) {
                HUD.error(title: "Private key is missing !!")
            }

//            if !restoreWalletFromKeychain() {
//                do {
//                    try createNewWallet()
//                } catch {
//                    print("error -> \(error)")
//                }
//            }
        }
    }

//    func getFlowAccountKey() -> AccountKey {
//        wallet?.
//    }

    func getMnemoic() -> String? {
        guard let wallet = wallet else {
            return nil
        }
        return wallet.mnemonic
    }

    @discardableResult
    func restoreWalletFromKeychain(username: String) -> Bool {
        if var mnemonicData: Data = try? keychain.getData("\(storeKey).\(username)"),
           var key = try? keychain.get(passwordKey)
        {
            if var data = try? WalletManager.decryptionAES(key: key, data: mnemonicData),
               var mnemonic = String(data: data, encoding: .utf8)
            {
                defer {
                    mnemonicData = Data()
                    data = Data()
                    key = ""
                    mnemonic = ""
                }

                wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
            }
            return true
        }
        return false
    }

//    func importNewWallet(mnemonic: String? = nil, passphrase: String = "") throws -> Bool {
//        if let phrase = mnemonic {
//            wallet = HDWallet(mnemonic: phrase, passphrase: passphrase)
//        } else {
//            wallet = HDWallet(strength: mnemonicStrength, passphrase: passphrase)
//        }
//
//        return true
//    }

    func createNewWallet(mnemonic: String? = nil, passphrase: String = "", forceCreate: Bool = false) throws -> Bool {
        // If there is already a wallet, we don't create a new wallet to replace current one
        if hasWallet, !forceCreate {
            HUD.debugError(title: "Already have a wallet !")
//            throw LLError.alreadyHaveWallet
            return false
        }

        if let phrase = mnemonic {
            wallet = HDWallet(mnemonic: phrase, passphrase: passphrase)
        } else {
            wallet = HDWallet(strength: mnemonicStrength, passphrase: passphrase)
        }
        return true
    }

    func storeMnemonicToKeychain(username: String) throws {
        guard let password = try? keychain.get(passwordKey) else {
            throw LLError.emptyEncryptKey
        }

        guard var mnemonic = wallet?.mnemonic,
              var data = mnemonic.data(using: .utf8)
        else {
            throw LLError.createWalletFailed
        }

        defer {
            mnemonic = ""
            data = Data()
        }

        let encodedData = try WalletManager.encryptionAES(key: password, data: data)

        try keychain
            .comment("Lilico user: \(username)")
            .set(encodedData, key: "\(storeKey).\(username)")
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
//        let hashKey = Hash.sha256(data: keyData).prefix(16)
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
//        let hashKey = Hash.sha256(data: keyData).prefix(16)
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
