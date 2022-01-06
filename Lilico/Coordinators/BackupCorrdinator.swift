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

final class BackupCorrdinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \BackupCorrdinator.recoveryPhrase)

    @Root var recoveryPhrase = createRecoveryPhrase
    @Route(.push) var manualBackup = makeManualBackup
    @Route(.push) var naviagteHome = makeHome
}

extension BackupCorrdinator {
    @ViewBuilder func createRecoveryPhrase() -> some View {
        RecoveryPhraseView(viewModel: RecoveryPhraseViewModel().toAnyViewModel())
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
