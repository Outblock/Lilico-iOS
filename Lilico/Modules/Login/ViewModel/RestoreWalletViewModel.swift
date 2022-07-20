//
//  RestoreWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 1/1/22.
//

import Foundation
import Stinsen

class RestoreWalletViewModel {
    @RouterObject var router: LoginCoordinator.Router?
}

// MARK: - Action

extension RestoreWalletViewModel {
    func restoreWithManualAction() {
        router?.route(to: \.inputMnemonic)
    }
    
    func restoreWithGoogleDriveAction() {
        BackupManager.shared.restore(from: .googleDrive)
    }
}
