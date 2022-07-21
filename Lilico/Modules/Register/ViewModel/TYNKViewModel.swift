//
//  TYNKViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import Resolver
import Stinsen

class TYNKViewModel: ViewModel {
    @Published private(set) var state = TYNKView.ViewState()
    var username: String

    @RouterObject var router: WalletCoordinator.Router?

    init(username: String) {
        self.username = username
    }

    func trigger(_ input: TYNKView.Action) {
        switch input {
        case .createWallet:
            registerAction()
        }
    }
    
    func registerAction() {
        state.isLoading = true
        
        Task {
            do {
                try await UserManager.shared.register(username)
                await MainActor.run {
                    state.isLoading = false
                    router?.popToRoot()
                    router?.coordinator.refreshRoot()
                    router?.route(to: \.recoveryPhrase)
                    HUD.success(title: "create_user_success".localized)
                }
            } catch {
                await MainActor.run {
                    state.isLoading = false
                    HUD.error(title: "create_user_failed".localized)
                }
            }
        }
    }
}
