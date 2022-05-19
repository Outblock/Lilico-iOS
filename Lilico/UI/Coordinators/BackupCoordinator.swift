//
//  BackupCorrdinator.swift
//  Lilico
//
//  Created by Hao Fu on 5/1/22.
//

import Foundation
import SwiftUI
import SwiftUIX

final class BackupCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \BackupCoordinator.recoveryPhrase)

    @Root var recoveryPhrase = createRecoveryPhrase
    @Route(.push) var manualBackup = makeManualBackup
    @Route(.push) var naviagteHome = makeHome
    @Route(.push) var backupPassword = makeBackupPassword
    @Route(.push) var requestSecure = makeRequestSecure
    @Route(.push) var createPin = makeCreatePin
}

extension BackupCoordinator {
    @ViewBuilder func createRecoveryPhrase() -> some View {
        RecoveryPhraseView(viewModel: RecoveryPhraseViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    @ViewBuilder func makeBackupPassword() -> some View {
        BackupPasswordView(viewModel: BackupPasswordViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    func makeRequestSecure() -> SecureCoordinator {
        SecureCoordinator()
    }

    func makeCreatePin() -> PinCodeCoordinator {
        PinCodeCoordinator()
    }

    @ViewBuilder func makeConfirmPinCode(lastPin: String) -> some View {
        ConfirmPinCodeView(viewModel: ConfirmPinCodeViewModel(pin: lastPin).toAnyViewModel())
            .hideNavigationBar()
    }

    @ViewBuilder func makeManualBackup() -> some View {
        ManualBackupView(viewModel: ManualBackupViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    func makeHome() -> HomeCoordinator {
        HomeCoordinator()
    }
}
