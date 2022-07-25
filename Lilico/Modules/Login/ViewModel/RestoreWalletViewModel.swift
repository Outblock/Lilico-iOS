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
        Router.route(to: RouteMap.RestoreLogin.restoreManual)
    }
    
    func restoreWithGoogleDriveAction() {
        HUD.loading()
        
        Task {
            do {
                let items = try await BackupManager.shared.getCloudDriveItems(from: .googleDrive)
                HUD.dismissLoading()
                
                if items.isEmpty {
                    HUD.error(title: "no_x_backup".localized("google_drive".localized))
                    return
                }
                
                DispatchQueue.main.async {
                    self.router?.route(to: \.chooseAccount, items)
                }
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "restore_with_x_failed".localized("google_drive".localized))
            }
        }
    }
}
