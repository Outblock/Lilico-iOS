//
//  AppPathDefine.swift
//  Lilico
//
//  Created by Selina on 8/6/2023.
//

import Foundation

protocol AppPathProtocol {
    var url: URL { get }
    var isExist: Bool { get }
    
    func remove() throws
    func createFolderIfNeeded()
}

extension AppPathProtocol {
    var isExist: Bool {
        return FileManager.default.fileExists(atPath: self.url.relativePath)
    }
    
    func remove() throws {
        if !isExist {
            return
        }
        
        try FileManager.default.removeItem(at: url)
    }
}

protocol AppFolderProtocol: AppPathProtocol {

}

extension AppFolderProtocol {
    func createFolderIfNeeded() {
        if isExist {
            return
        }
        
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            log.error("create folder failed", context: error)
        }
    }
}

protocol AppFileProtocol: AppPathProtocol {
    
}

extension AppFileProtocol {
    func createFolderIfNeeded() {
        let folder = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: folder.relativePath) {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                log.error("create folder failed", context: error)
            }
        }
    }
}

enum AppFolderType: AppFolderProtocol {
    case applicationSupport
    case accountInfoRoot                        // ./account_info
    case userStorage(String)                    // ./account_info/1234
    
    var url: URL {
        switch self {
        case .applicationSupport:
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        case .accountInfoRoot:
            return AppFolderType.applicationSupport.url.appendingPathComponent("account_info")
        case .userStorage(let uid):
            return AppFolderType.accountInfoRoot.url.appendingPathComponent(uid)
        }
    }
}

enum UserStorageFileType: AppFileProtocol {
    case userInfo(String)                       // ./account_info/1234/user_info
    case walletInfo(String)                     // ./account_info/1234/wallet_info
    case userDefaults(String)                   // ./account_info/1234/user_defaults
    case childAccounts(String, String)          // ./account_info/1234/0x12345678/child_accounts
    
    var url: URL {
        switch self {
        case .userInfo(let uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("user_info")
        case .walletInfo(let uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("wallet_info")
        case .userDefaults(let uid):
            return AppFolderType.userStorage(uid).url.appendingPathComponent("user_defaults")
        case .childAccounts(let uid, let address):
            return AppFolderType.userStorage(uid).url.appendingPathComponent(address).appendingPathComponent("child_accounts")
        }
    }
}
