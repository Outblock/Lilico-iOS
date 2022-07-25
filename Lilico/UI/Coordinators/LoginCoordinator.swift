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
    @Route(.push) var enterRestorePwd = makeEnterRestorePassword

    @ViewBuilder func makeRestore() -> some View {
        RestoreWalletView()
    }

    @ViewBuilder func makeInputMnemonic() -> some View {
        InputMnemonicView()
    }
    
    @ViewBuilder func makeChooseAccount(items: [BackupManager.DriveItem]) -> some View {
        ChooseAccountView(driveItems: items)
    }
    
    @ViewBuilder func makeEnterRestorePassword(item: BackupManager.DriveItem) -> some View {
        EnterRestorePasswordView(driveItem: item)
    }
}
