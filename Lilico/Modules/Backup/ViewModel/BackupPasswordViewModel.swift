//
//  BackupPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI


class BackupPasswordViewModel: ObservableObject {
    private var backupType: BackupManager.BackupType

    init(backupType: BackupManager.BackupType) {
        self.backupType = backupType
    }
    
    func backupToCloudAction(password: String) {
        HUD.loading()
        
        Task {
            do {
                try await BackupManager.shared.uploadMnemonic(to: backupType, password: password)
                setWebPassword(password: password)
                
                HUD.dismissLoading()
                
                Router.popToRoot()
                HUD.success(title: "backup_to_x_succeeded".localized(self.backupType.descLocalizedString))
            } catch BackupError.fileIsNotExistOnCloud {
                HUD.dismissLoading()
                HUD.error(title: "no_x_backup".localized(self.backupType.descLocalizedString))
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "backup_to_x_failed".localized(self.backupType.descLocalizedString))
            }
        }
    }
    
    private func setWebPassword(password: String) {
        if let uid = UserManager.shared.getUid(), !uid.isEmpty {
            try? WalletManager.shared.setSecurePassword(password, uid: uid)
        }
    }
}
