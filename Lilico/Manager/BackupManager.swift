//
//  BackupManager.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import FirebaseAuth
import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore

// protocol BackupDelegate {
// }

class BackupManager: ObservableObject {
    static let backupName = "Lilico-backup"

    struct StoreData: Codable {
        let users: [String]
        let data: [String]
    }

    struct AccountData: Codable {
        var version: String = "1.0"
        let data: String
        let address: [String]
        let name: String
    }

    static let shared = BackupManager()

    var hasBackup: Bool {
        return icloudStore.string(forKey: BackupManager.backupName) != nil
    }

    var icloudStore = NSUbiquitousKeyValueStore()

    init() {
        icloudStore.removeObject(forKey: BackupManager.backupName)
    }

    func setAccountDatatoiCloud() throws {
        guard let user = Auth.auth().currentUser,
              !user.isAnonymous,
              let userInfo = UserManager.shared.userInfo,
              let wallet = WalletManager.shared.wallet,
              let data = wallet.mnemonic.data(using: .utf8)
        else {
            throw LLError.missingUserInfoWhilBackup
        }

        let encryptData = try WalletManager.encryptionAES(key: userInfo.userName, data: data)
        let accountData = AccountData(data: encryptData.hexValue, address: [userInfo.address ?? ""], name: userInfo.userName)
        let jsonData = try JSONEncoder().encode(accountData)
        let storeData = try WalletManager.encryptionAES(key: WalletManager.encryptionKey, data: jsonData)
        let finalData = StoreData(users: [userInfo.userName], data: [storeData.base64EncodedString()])
        let finalJsonData = try JSONEncoder().encode(finalData)
        icloudStore.set(finalJsonData.base64EncodedString(), forKey: BackupManager.backupName)
        icloudStore.synchronize()
    }

    func getBackupNameList() throws -> [String] {
        guard let dataString = icloudStore.string(forKey: BackupManager.backupName) else {
            throw LLError.emptyiCloudBackup
        }

        guard let data = Data(base64Encoded: dataString) else {
            throw LLError.decryptBackupFailed
        }

        let model = try JSONDecoder().decode(StoreData.self, from: data)
        return model.users
    }

    func loadAccountDataFromiCloud(userName: String) throws {
        guard let dataString = icloudStore.string(forKey: BackupManager.backupName) else {
            throw LLError.emptyiCloudBackup
        }

        guard let data = Data(base64Encoded: dataString) else {
            throw LLError.decryptBackupFailed
        }

        let model = try JSONDecoder().decode(StoreData.self, from: data)
        guard let index = model.users.firstIndex(of: userName),
              let storeString = model.data[safe: index],
              let storeData = Data(base64Encoded: storeString)
        else {
            throw LLError.decryptBackupFailed
        }

        let jsonData = try WalletManager.decryptionAES(key: WalletManager.encryptionKey, data: storeData)
        let accountData = try JSONDecoder().decode(AccountData.self, from: jsonData)
        let encryptData = try WalletManager.decryptionAES(key: accountData.name, data: Data(hexString: accountData.data) ?? Data())
        guard let mnemonic = String(data: encryptData, encoding: .utf8) else {
            throw LLError.emptyiCloudBackup
        }
        try WalletManager.shared.createNewWallet(mnemonic: mnemonic, forceCreate: true)
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
