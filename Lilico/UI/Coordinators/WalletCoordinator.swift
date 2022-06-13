//
//  HomeCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Combine
import SwiftUI

final class WalletCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<WalletCoordinator>

    private var cancellables = Set<AnyCancellable>()

    @Root var start = makeStart
    @Root var empty = makeEmptyWallet
    @Route(.push) var register = makeRegister
    @Route(.push) var login = makeLogin

    @Route(.push) var recoveryPhrase = makeRecoveryPhrase

    @Route(.push) var createSecure = makeCreateSecure

    var isFristTime: Bool = true

    init() {
        stack = NavigationStack(initial: \WalletCoordinator.empty)
    }
}

extension WalletCoordinator {
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

extension WalletCoordinator: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .wallet
    }
    
    static func iconName() -> String {
        return "house.fill"
    }
    
    static func color() -> Color {
        return .LL.orange
    }
}