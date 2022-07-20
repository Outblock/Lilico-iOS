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
    func getCurrentDriveItems() async throws -> [BackupManager.DriveItem]
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
        var uid: String?
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
//            gdTarget.uploadMnemonic(password: password)
            break
        case .icloud:
            break
        default:
            break
        }
    }
    
    func restore(from type: BackupManager.BackupType) {
        switch type {
        case .googleDrive:
            Task {
                do {
                    let fileId = try await gdTarget.testGetFileId()
                    debugPrint("BackupManager -> fileId = \(fileId)")
                } catch {
                    debugPrint("BackupManager -> restore with google drive failed: \(error)")
                }
            }
        case .icloud:
            break
        default:
            break
        }
    }
    
    func getCloudDriveItems(from type: BackupManager.BackupType) async throws -> [BackupManager.DriveItem] {
        return []
    }
}

class BackupManager: ObservableObject {
    static let shared = BackupManager()
    
    private let gdTarget = BackupGDTarget()
}

// MARK: - Helper

extension BackupManager {
    /// append current user mnemonic to list with encrypt
    func addCurrentMnemonicToList(_ list: [BackupManager.DriveItem], password: String) throws -> [BackupManager.DriveItem] {
        guard let username = UserManager.shared.userInfo?.username, !username.isEmpty else {
            throw BackupError.missingUserName
        }
        
        guard let mnemonic = WalletManager.shared.getCurrentMnemonic(), !mnemonic.isEmpty, let mnemonicData = mnemonic.data(using: .utf8) else {
            throw BackupError.missingMnemonic
        }
        
        let dataHexString = try encryptMnemonic(mnemonicData, password: password)
        
        let existItem = list.first { item in
            item.username == username
        }
        
        if let existItem = existItem {
            existItem.version = "1"
            existItem.data = dataHexString
            return list
        }
        
        guard let uid = UserManager.shared.getUid(), !uid.isEmpty else {
            throw BackupError.missingUid
        }
        
        let item = BackupManager.DriveItem()
        item.username = username
        item.uid = uid
        item.version = "1"
        item.data = dataHexString
        
        var newList = [item]
        newList.append(contentsOf: list)
        return newList
    }
    
    /// encrypt list to hex string
    func encryptList(_ list: [BackupManager.DriveItem]) throws -> String {
        let jsonData = try JSONEncoder().encode(list)
        let encrypedData = try WalletManager.encryptionAES(key: BackupManager.backupAESKey, data: jsonData)
        return encrypedData.hexString
    }
    
    /// decrypt hex string to list
    func decryptHexString(_ hexString: String) throws -> [BackupManager.DriveItem] {
        guard let data = Data(hexString: hexString) else {
            throw BackupError.hexStringToDataFailed
        }
        
        return try decryptData(data)
    }
    
    private func decryptData(_ data: Data) throws -> [BackupManager.DriveItem] {
        let jsonData = try WalletManager.decryptionAES(key: BackupManager.backupAESKey, data: data)
        let list = try JSONDecoder().decode([BackupManager.DriveItem].self, from: jsonData)
        return list
    }
    
    /// encrypt mnemonic data to hex string
    func encryptMnemonic(_ mnemonicData: Data, password: String) throws -> String {
        let dataHexString = try WalletManager.encryptionAES(key: password, data: mnemonicData).hexString
        return dataHexString
    }
    
    /// decrypt hex string to mnemonic string
    func decryptMnemonic(_ hexString: String, password: String) throws -> String {
        guard let encryptData = Data(hexString: hexString) else {
            throw BackupError.hexStringToDataFailed
        }
        
        let decryptedData = try WalletManager.decryptionAES(key: password, data: encryptData)
        guard let mm = String(data: decryptedData, encoding: .utf8), !mm.isEmpty else {
            throw BackupError.decryptMnemonicFailed
        }
        
        return mm
    }
}
