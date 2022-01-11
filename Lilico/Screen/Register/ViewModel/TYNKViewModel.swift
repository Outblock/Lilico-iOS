//
//  TYNKViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import Resolver

class TYNKViewModel: ViewModel {
    @Published
    private(set) var state = TYNKView.ViewState()

    @Injected
    var walletManager: WalletManager

    var userManager = UserManager.shared

    var username: String
    var router: RegisterCoordinator.Router? = RouterStore.shared.retrieve()

    @RouterObject
    var homeRouter: HomeCoordinator.Router?

    init(username: String) {
        self.username = username
    }

    func trigger(_ input: TYNKView.Action) {
        switch input {
        case .createWallet:
            Task {
                await MainActor.run {
                    state.isLoading = true
                }
                do {
                    try await UserManager.shared.register(username)
                    await MainActor.run {
                        // TODO: - Fix the pop back animation
                        homeRouter?
                            .popToRoot()
                            .route(to: \.recoveryPhrase)
                        HUD.success(title: "Create User Success!")
                        state.isLoading = false
                    }
                } catch {
                    print("error: \(error)")
                    await MainActor.run {
                        state.isLoading = false
                        HUD.error(title: "Create User Failed")
                    }
                }
            }
        }
    }
}
