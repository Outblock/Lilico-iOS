//
//  HomeCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Combine
import Stinsen
import SwiftUI

final class HomeCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<HomeCoordinator>

    private var cancellables = Set<AnyCancellable>()

    @Root var start = makeStart
    @Root var empty = makeEmptyWallet
    @Route(.push) var register = makeRegister
    @Route(.push) var login = makeLogin

    @Route(.push) var recoveryPhrase = makeRecoveryPhrase

    @Route(.push) var createSecure = makeCreateSecure
    
    var isFristTime: Bool = true

    init() {
//        if UserManager.shared.isLoggedIn {
//            stack = NavigationStack(initial: \HomeCoordinator.start)
//        } else {
//            stack = NavigationStack(initial: \HomeCoordinator.empty)
//        }
        stack = NavigationStack(initial: \HomeCoordinator.empty)
    }

//    func customize(_ view: AnyView) -> some View {
//        sharedView(view)
//    }
//
//    @ViewBuilder func sharedView(_ view: AnyView) -> some View {
//        view.onReceive(UserManager.shared.$isAnonymous) { isAnonymous in
//            if isAnonymous {
//                self.root(\.empty)
//            } else {
//                self.root(\.start)
//            }
//        }
//    }

    @ViewBuilder func makeEmptyWallet() -> some View {
        EmptyWalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    @ViewBuilder func makeStart() -> some View {
        WalletView()
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

    func makeRecoveryPhrase() -> BackupCoordinator {
        BackupCoordinator()
    }
    
    func makeCreateSecure() -> SecureCoordinator {
        SecureCoordinator()
    }
}
