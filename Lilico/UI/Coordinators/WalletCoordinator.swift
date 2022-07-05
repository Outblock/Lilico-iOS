//
//  HomeCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Combine
import Stinsen
import SwiftUI

final class WalletCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: UserManager.shared.isLoggedIn ? \WalletCoordinator.start : \WalletCoordinator.empty)

    private var cancellables = Set<AnyCancellable>()

    @Root var start = makeStart
    @Root var empty = makeEmptyWallet
    @Route(.push) var register = makeRegister
    @Route(.push) var login = makeLogin
    @Route(.push) var recoveryPhrase = makeRecoveryPhrase
    @Route(.push) var createSecure = makeCreateSecure
    @Route(.push) var addToken = makeAddToken
    @Route(.push) var tokenDetail = makeTokenDetail

    var isFristTime: Bool = true

    private var cancelSets = Set<AnyCancellable>()

    init() {
        UserManager.shared.$isLoggedIn.sink { [weak self] isLoggedIn in
            DispatchQueue.main.async {
                self?.root(isLoggedIn ? \.start : \.empty)
            }
        }.store(in: &cancelSets)
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
    
    func makeAddToken() -> some View {
        AddTokenView()
    }
    
    func makeTokenDetail(token: TokenModel) -> some View {
        TokenDetailView(token: token)
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
