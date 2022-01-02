//
//  HomeCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Stinsen
import SwiftUI

final class HomeCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \HomeCoordinator.start)

    @Root var start = makeStart
    @Route(.push) var register = makeRegister
    @Route(.push) var login = makeLogin

    @ViewBuilder func makeStart() -> some View {
        EmptyWalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    func makeRegister() -> RegisterCoordinator {
        RegisterCoordinator()
    }

    func makeLogin() -> LoginCoordinator {
        LoginCoordinator()
    }

    func routeToAuthenticated() {
        route(to: \.register)
    }
}
