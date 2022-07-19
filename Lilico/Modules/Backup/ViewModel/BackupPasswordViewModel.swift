//
//  BackupPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Foundation
import Stinsen

class BackupPasswordViewModel: ViewModel {
    @Published
    private(set) var state: BackupPasswordView.ViewState

    @RouterObject
    var router: BackupCoordinator.Router?

    @RouterObject
    var homeRouter: WalletCoordinator.Router?

    init(backupType: BackupManager.BackupType) {
        state = .init(backupType: backupType, uid: UserManager.shared.getUid() ?? "unknown_uid")
    }

    func trigger(_ input: BackupPasswordView.Action) {
        switch input {
        case let .secureBackup(password):
            // TODO: backup to cloud
            BackupManager.shared.uploadMnemonic(to: state.backupType, password: password)
            setWebPassword(password: password)
        default:
            break
        }
    }
    
    private func setWebPassword(password: String) {
        try? WalletManager.shared.setSecurePassword(password, uid: state.uid)
    }
}
