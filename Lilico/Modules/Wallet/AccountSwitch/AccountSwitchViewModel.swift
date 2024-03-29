//
//  AccountSwitchViewModel.swift
//  Lilico
//
//  Created by Selina on 13/6/2023.
//

import SwiftUI
import Combine

extension AccountSwitchViewModel {
    struct Placeholder {
        let uid: String
        let avatar: String
        let username: String
        let address: String
    }
}

class AccountSwitchViewModel: ObservableObject {
    @Published var placeholders: [Placeholder] = []
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        UserManager.shared.$loginUIDList
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] list in
                guard let self = self else { return }
                self.placeholders = list.map { uid in
                    let userInfo = MultiAccountStorage.shared.getUserInfo(uid)
                    let address = MultiAccountStorage.shared.getWalletInfo(uid)?.currentNetworkWalletModel?.getAddress ?? "0x"

                    return Placeholder(uid: uid, avatar: userInfo?.avatar ?? "", username: userInfo?.username ?? "", address: address)
                }
            }.store(in: &cancelSets)
    }
    
    func createNewAccountAction() {
        Router.route(to: RouteMap.Register.root(nil))
    }
    
    func loginAccountAction() {
        Router.route(to: RouteMap.RestoreLogin.root)
    }
    
    func switchAccountAction(_ uid: String) {
        Task {
            do {
                HUD.loading()
                try await UserManager.shared.switchAccount(withUID: uid)
                HUD.dismissLoading()
            } catch {
                log.error("switch account failed", context: error)
                HUD.dismissLoading()
                HUD.error(title: error.localizedDescription)
            }
        }
    }
}
