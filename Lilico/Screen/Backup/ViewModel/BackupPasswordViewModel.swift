//
//  BackupPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Foundation

class BackupPasswordViewModel: ViewModel {
    @Published
    private(set) var state: BackupPasswordView.ViewState

    @RouterObject
    var router: BackupCoordinator.Router?

    @RouterObject
    var homeRouter: HomeCoordinator.Router?

    init() {
        state = .init(username: UserManager.shared.userInfo?.username ?? "user")
    }

    func trigger(_ input: BackupPasswordView.Action) {
        switch input {
        case let .onPasswordChanged(password):
            break
        case let .onConfirmChanged(confirmPassword):
            break
        case let .secureBackup(password):
            do {
                try WalletManager.shared.backupKeychain.set(password, key: state.username)
                try BackupManager.shared.setAccountDatatoiCloud(password: password)

                homeRouter?
                    .popToRoot()
                    .route(to: \.createSecure)
            } catch {
                HUD.error(title: "Backup failed")
                debugPrint(error)
            }
        default:
            break
        }
    }
}
