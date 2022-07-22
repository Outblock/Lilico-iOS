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
    case restoreLoginFailed
    case accountNotFound
    case fetchUserInfoFailed
    case invalidAddress
    case signFailed
    case unknown
}

enum WalletError: Error {
    case fetchFailed
    case fetchBalanceFailed
}

enum BackupError: Error {
    case missingUserName
    case missingMnemonic
    case missingUid
    case hexStringToDataFailed
    case decryptMnemonicFailed
    case topVCNotFound
}

enum GoogleBackupError: Error {
    case missingLoginUser
    case noDriveScope
    case createFileError
}
