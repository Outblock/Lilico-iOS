//
//  Error.swift
//  Lilico
//
//  Created by Selina on 8/6/2022.
//

import Foundation

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
