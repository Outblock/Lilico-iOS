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

    @ViewBuilder func makeRestore() -> some View {
        RestoreWalletView(viewModel: .init())
    }

    @ViewBuilder func makeInputMnemonic() -> some View {
        InputMnemonicView(viewModel: InputMnemonicViewModel())
    }
}
