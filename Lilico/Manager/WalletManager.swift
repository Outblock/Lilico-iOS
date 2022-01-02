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
}

class WalletManager: ObservableObject {
    static let flowPath = "m/44'/539'/0'/0/0"
    private let storeKey = "lilico.mnemonic"
    private let encryptionKey = "4047b6b927bcff0c"

    var hasWallet: Bool {
        return wallet != nil
    }

    private var wallet: HDWallet?

    let mnemonicStrength: Int32 = 128
    var defaultBundleID = "io.outblock.lilico"
    let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "defaultBundleID")
        .label("Lilico app backup")
        .synchronizable(true)
        .accessibility(.whenUnlocked)

    init() {
        restoreWalletFromKeychain()
    }

    @discardableResult
    func restoreWalletFromKeychain() -> Bool {
        if let mnemonic = try? keychain.get(storeKey) {
            wallet = HDWallet(mnemonic: mnemonic, passphrase: "")
            return true
        }
        return false
    }

    func createNewWallet(mnemonic: String? = nil, passphrase: String = "", forceCreate: Bool = false) throws {
        // If there is already a wallet, we don't create a new wallet to replace current one
        if hasWallet, !forceCreate {
            return
        }

        let wallet = HDWallet(strength: mnemonicStrength, passphrase: passphrase)
        guard var mnemonic = wallet?.mnemonic else {
            throw LLError.createWalletFailed
        }

        defer {
            mnemonic = ""
        }

        try keychain
            .comment("Lilico")
            .set(mnemonic, key: storeKey)

//        let pk = wallet?.getCurveKey(curve: .nist256p1, derivationPath: flowPath)
    }

    func encryptionAES(key: String, iv: String = "0102030405060708", data: Data) throws -> Data {
        guard let keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            throw LLError.aesKeyEncryptionFailed
        }
        guard let encrypted = AES.encryptCBC(key: keyData, data: data, iv: ivData, mode: .pkcs7) else {
            throw LLError.aesEncryptionFailed
        }
        return encrypted
    }
}

extension HDWallet {
    var flowAccountKey: Flow.AccountKey {
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

extension String {
    func dropPrefix(_ prefix: String) -> Self {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}
