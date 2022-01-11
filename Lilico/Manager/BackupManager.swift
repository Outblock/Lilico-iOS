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
import WalletCore

// protocol BackupDelegate {
// }

enum BackupType {
    case icloud
    case googleDrive
    case manual
}

class BackupManager: ObservableObject {
    static let backupName = "Lilico-backup"

    struct AccountData: Codable {
        let data: String
        let username: String
    }
    
//    struct StoreData: Codable {
//        let users: [String]
//        let data: [String]
//    }
//
//    struct AccountData: Codable {
//        var version: String = "1.0"
//        let data: String
//        let address: [String]
//        let name: String
//    }

    static let shared = BackupManager()

    var hasBackup: Bool {
        return icloudStore.string(forKey: BackupManager.backupName) != nil
    }

    var icloudStore = NSUbiquitousKeyValueStore()

    init() {
//        icloudStore.removeObject(forKey: BackupManager.backupName)
        icloudStore.synchronize()
    }

    func setAccountDatatoiCloud(password: String) throws {
        guard let user = Auth.auth().currentUser,
              !user.isAnonymous,
              let userInfo = UserManager.shared.userInfo,
              let userData = userInfo.username.data(using: .utf8),
              let wallet = WalletManager.shared.wallet,
              let data = wallet.mnemonic.data(using: .utf8)
        else {
            throw LLError.missingUserInfoWhilBackup
        }
        
        let iv = Hash.sha256(data: userData).hexValue
        let encryptData = try WalletManager.encryptionAES(key: password, iv: String(iv.prefix(16)), data: data)
        let accountData = AccountData(data: encryptData.base64EncodedString(), username: userInfo.username)
        
        var storedData = loadAccountDataFromiCloud() ?? []
        storedData.append(accountData)
        
//        let accountData = AccountData(data: encryptData.hexValue, address: [userInfo.address ?? ""], name: userInfo.username)
        let jsonData = try JSONEncoder().encode(storedData)
//        let storeData = try WalletManager.encryptionAES(key: WalletManager.encryptionKey, data: jsonData)
//        let finalData = StoreData(users: [userInfo.username], data: [storeData.base64EncodedString()])
//        let finalJsonData = try JSONEncoder().encode(finalData)
        icloudStore.set(jsonData, forKey: BackupManager.backupName)
        icloudStore.synchronize()
    }
    
    func loadAccountDataFromiCloud() -> [AccountData]? {
        guard let data = icloudStore.data(forKey: BackupManager.backupName) else {
//            throw LLError.emptyiCloudBackup
            return nil
        }
        
//        guard let data = dataString.data(using: .utf8) else {
////            throw LLError.decryptBackupFailed
//            return nil
//        }
        
        do {
            let model = try JSONDecoder().decode([AccountData].self, from: data)
            return model
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func decryptAccountData(password: String, account: AccountData) throws -> String {
        guard let data = Data(base64Encoded: account.data),
              let userData = account.username.data(using: .utf8) else {
            throw LLError.decryptBackupFailed
        }
        
        let iv = Hash.sha256(data: userData).hexValue
        var keyData = try WalletManager.decryptionAES(key: password, iv: String(iv.prefix(16)), data: data)
        guard var key = String(data: keyData, encoding: .utf8) else {
            throw LLError.decryptBackupFailed
        }
        
        defer {
            key = ""
            keyData = Data()
        }
        
        return key
    }

    func getBackupNameList() -> [String] {
        if let storedData = loadAccountDataFromiCloud() {
            return storedData.map{ $0.username }
        }
        return []
    }
    
//    func loadAccountDataFromiCloud(username: String) throws {
//        guard let dataString = icloudStore.string(forKey: BackupManager.backupName) else {
//            throw LLError.emptyiCloudBackup
//        }
//
//        guard let data = Data(base64Encoded: dataString) else {
//            throw LLError.decryptBackupFailed
//        }
//
//        let model = try JSONDecoder().decode(StoreData.self, from: data)
//        guard let index = model.users.firstIndex(of: username),
//              let storeString = model.data[safe: index],
//              let storeData = Data(base64Encoded: storeString)
//        else {
//            throw LLError.decryptBackupFailed
//        }
//
//        let jsonData = try WalletManager.decryptionAES(key: WalletManager.encryptionKey, data: storeData)
//        let accountData = try JSONDecoder().decode(AccountData.self, from: jsonData)
//        let encryptData = try WalletManager.decryptionAES(key: accountData.name, data: Data(hexString: accountData.data) ?? Data())
//        guard let mnemonic = String(data: encryptData, encoding: .utf8) else {
//            throw LLError.emptyiCloudBackup
//        }
//        try WalletManager.shared.createNewWallet(mnemonic: mnemonic, forceCreate: true)
//    }
}


