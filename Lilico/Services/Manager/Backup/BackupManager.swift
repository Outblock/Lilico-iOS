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

protocol BackupTarget {
    func uploadMnemonic(password: String) throws
    func getCurrentDriveItems() -> [BackupManager.DriveItem]
}

extension BackupManager {
    enum BackupType {
        case icloud
        case googleDrive
        case manual
    }
    
    static let backupFileName = "outblock_backup"
    private static let backupAESKey = "4047b6b927bcff0c"
}

extension BackupManager {
    class DriveItem: Codable {
        var username: String
        var uid: String
        var data: String
        var version: String
        var time: String?
        
        init() {
            username = ""
            uid = ""
            data = ""
            version = ""
        }
    }
}

extension BackupManager {
    func uploadMnemonic(to type: BackupManager.BackupType, password: String) {
        switch type {
        case .googleDrive:
            gdTarget.uploadMnemonic(password: password)
        case .icloud:
            break
        default:
            break
        }
    }
}

// MARK: - Helper

extension BackupManager {
    func addCurrentMnemonicToList(_ list: [BackupManager.DriveItem], password: String) throws -> [BackupManager.DriveItem] {
        guard let username = UserManager.shared.userInfo?.username, !username.isEmpty else {
            throw BackupError.missingUserName
        }
        
        guard let mnemonic = WalletManager.shared.getCurrentMnemonic(), !mnemonic.isEmpty, let mnemonicData = mnemonic.data(using: .utf8) else {
            throw BackupError.missingMnemonic
        }
        
        let dataHexString = try WalletManager.encryptionAES(key: password, data: mnemonicData).hexString
        
        let existItem = list.first { item in
            item.username == username
        }
        
        if let existItem = existItem {
            existItem.version = "1.0"
            existItem.data = dataHexString
            return list
        }
        
        guard let uid = UserManager.shared.getUid(), !uid.isEmpty else {
            throw BackupError.missingUid
        }
        
        let item = BackupManager.DriveItem()
        item.username = username
        item.uid = uid
        item.version = "1.0"
        item.data = dataHexString
        
        var newList = [item]
        newList.append(contentsOf: list)
        return newList
    }
    
    func encryptList(_ list: [BackupManager.DriveItem]) throws -> String {
        let jsonData = try JSONEncoder().encode(list)
        let encrypedData = try WalletManager.encryptionAES(key: BackupManager.backupAESKey, data: jsonData)
        return encrypedData.hexString
    }
    
    func decryptData(_ data: Data) throws -> [BackupManager.DriveItem] {
        let jsonData = try WalletManager.decryptionAES(key: BackupManager.backupAESKey, data: data)
        let list = try JSONDecoder().decode([BackupManager.DriveItem].self, from: jsonData)
        return list
    }
}

class BackupManager: ObservableObject {
    static let shared = BackupManager()
    
    private let gdTarget = BackupGDTarget()

//    var hasBackup: Bool {
//        return icloudStore.string(forKey: BackupManager.backupName) != nil
//    }

//    var icloudStore = NSUbiquitousKeyValueStore()

    init() {
//        icloudStore.synchronize()
    }

//    func setAccountDatatoiCloud(password: String) throws {
//        guard let user = Auth.auth().currentUser,
//              !user.isAnonymous,
//              let userInfo = UserManager.shared.userInfo,
//              let userData = userInfo.username.data(using: .utf8),
//              let mnemonic = WalletManager.shared.getCurrentMnemonic(),
//              let data = mnemonic.data(using: .utf8)
//        else {
//            throw LLError.missingUserInfoWhilBackup
//        }
//
//        let iv = Hash.sha256(data: userData).hexValue
//        let encryptData = try WalletManager.encryptionAES(key: password, iv: String(iv.prefix(16)), data: data)
//        let accountData = AccountData(data: encryptData.base64EncodedString(), username: userInfo.username)
//
//        var storedData = loadAccountDataFromiCloud() ?? []
//        storedData.append(accountData)
//
//        let jsonData = try JSONEncoder().encode(storedData)
//        icloudStore.set(jsonData, forKey: BackupManager.backupName)
//        icloudStore.synchronize()
//    }

//    func loadAccountDataFromiCloud() -> [AccountData]? {
//        guard let data = icloudStore.data(forKey: BackupManager.backupName) else {
//            return nil
//        }
//
//        do {
//            let model = try JSONDecoder().decode([AccountData].self, from: data)
//            return model
//        } catch {
//            print(error)
//        }
//
//        return nil
//    }

    func decryptDriveItem(password: String, item: BackupManager.DriveItem) throws -> String {
        guard let data = Data(base64Encoded: item.data),
              let userData = item.username.data(using: .utf8)
        else {
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

//    func getBackupNameList() -> [String] {
//        if let storedData = loadAccountDataFromiCloud() {
//            return storedData.map { $0.username }
//        }
//        return []
//    }

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
