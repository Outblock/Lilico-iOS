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
    @Published
    private(set) var state = TYNKView.ViewState()

    @Injected
    var walletManager: WalletManager

    @Injected
    var userManager: UserManager

    var userName: String
    var router: RegisterCoordinator.Router? = RouterStore.shared.retrieve()

    init(userName: String) {
        self.userName = userName
    }

    func trigger(_ input: TYNKView.Action) {
        switch input {
        case .createWallet:
            guard let key = walletManager.wallet?.flowAccountKey else {
                HUD.error(title: "Create User Failed")
                return
            }
            Task {
                await MainActor.run {
                    state.isLoading = true
                }
                let request = RegisterReuqest(userName: userName, accountKey: key.toCodableModel())
                do {
                    let model: RegisterResponse = try await Network.request(LilicoEndpoint.register(request))
                    try await userManager.loginWithCustomToken(model.customToken)
                    let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoEndpoint.userAddress)

                    await MainActor.run {
                        router?.route(to: \.recoveryPhrase)
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
