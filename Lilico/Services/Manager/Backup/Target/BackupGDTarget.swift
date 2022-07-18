//
//  BackupGDTarget.swift
//  Lilico
//
//  Created by Selina on 18/7/2022.
//

import Foundation

class BackupGDTarget: BackupTarget {
    func getCurrentDriveItems() -> [BackupManager.DriveItem] {
        return []
    }
    
    func uploadMnemonic(password: String) throws {
        let list = try BackupManager.shared.addCurrentMnemonicToList(getCurrentDriveItems(), password: password)
        let encrypedString = try BackupManager.shared.encryptList(list)
    }
}
