//
//  LoginCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 1/1/22.
//

import Stinsen
import SwiftUI

final class LoginCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \LoginCoordinator.restore)

    @Root var restore = makeRestore
    @Route(.push) var inputMnemonic = makeInputMnemonic
    @Route(.push) var chooseAccount = makeChooseAccount
    @Route(.push) var enterPassword = makeEnterPassword
    

    @ViewBuilder func makeRestore() -> some View {
        RestoreWalletView(viewModel: .init())
            .hideNavigationBar()
    }

    @ViewBuilder func makeInputMnemonic() -> some View {
        InputMnemonicView(viewModel: InputMnemonicViewModel().toAnyViewModel())
            .hideNavigationBar()
    }
    
    @ViewBuilder func makeEnterPassword(accountData: BackupManager.AccountData) -> some View {
        EnterPasswordView(viewModel: EnterPasswordViewModel(account: accountData).toAnyViewModel())
            .hideNavigationBar()
    }
    
    @ViewBuilder func makeChooseAccount(accountList: [BackupManager.AccountData]) -> some View {
        ChooseAccountView(viewModel: ChooseAccountViewModel(accountList: accountList).toAnyViewModel())
            .hideNavigationBar()
    }
}
