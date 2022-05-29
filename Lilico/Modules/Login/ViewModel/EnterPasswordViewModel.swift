//
//  EnterPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation

class EnterPasswordViewModel: ViewModel {
    @Published
    private(set) var state: EnterPasswordView.ViewState = .init()

    @RouterObject
    var router: LoginCoordinator.Router?

    let account: BackupManager.AccountData

    init(account: BackupManager.AccountData) {
        self.account = account
    }

    func trigger(_ input: EnterPasswordView.Action) {
        switch input {
        case let .signIn(password):
            do {
                let mnemonic = try BackupManager.shared.decryptAccountData(password: password, account: account)
                print(mnemonic)
//                WalletManager.
                HUD.success(title: "Success !")
            } catch {
                HUD.error(title: "Incorrect password")
            }
        }
    }
}