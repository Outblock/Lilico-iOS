//
//  HomeCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import SwiftUI
import Stinsen

final class HomeCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \HomeCoordinator.start)

    @Root var start = makeStart
    @Route(.push) var register = makeRegister

    @ViewBuilder func makeStart() -> some View {
        EmptyWalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
            .hideNavigationBar()
    }
    
    func makeRegister() -> RegisterCoordinator {
        RegisterCoordinator()
    }
    
    func routeToAuthenticated() {
        route(to: \.register)
    }
}
