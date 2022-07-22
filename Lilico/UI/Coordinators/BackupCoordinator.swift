//
//  BackupCorrdinator.swift
//  Lilico
//
//  Created by Hao Fu on 5/1/22.
//

import Foundation
import Stinsen
import SwiftUI
import SwiftUIX

final class BackupCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \BackupCoordinator.recoveryPhrase)

    @Root var recoveryPhrase = createRecoveryPhrase
    @Route(.push) var manualBackup = makeManualBackup
    @Route(.push) var backupPassword = makeBackupPassword
    @Route(.push) var requestSecure = makeRequestSecure
}

extension BackupCoordinator {
    @ViewBuilder func createRecoveryPhrase() -> some View {
        RecoveryPhraseView(viewModel: RecoveryPhraseViewModel().toAnyViewModel())
    }

    @ViewBuilder func makeBackupPassword(backupType: BackupManager.BackupType) -> some View {
        BackupPasswordView(backupType: backupType)
    }

    func makeRequestSecure() -> SecureCoordinator {
        SecureCoordinator()
    }

    @ViewBuilder func makeManualBackup() -> some View {
        ManualBackupView(viewModel: ManualBackupViewModel().toAnyViewModel())
            .hideNavigationBar()
    }
}
