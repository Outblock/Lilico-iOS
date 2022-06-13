//
//  EmptyWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import Foundation
import SwiftUI
import SwiftUIX

class EmptyWalletViewModel: ViewModel {
    @Published
    private(set) var state: EmptyWalletState

//    @RouterObject
//    var router: NavigationRouter<HomeCoordinator>!

    var router: WalletCoordinator.Router? = RouterStore.shared.retrieve()

    init() {
        let dataSource = [
            CardDataSource(title: "create_btn_desc".localized,
                           bgGradient: [.red, Color.LL.orange],
                           bgImage: Image(componentAsset: "Gradient-Circle")
                               .renderingMode(.original),
                           buttonText: "create_btn_text".localized,
                           icon: Image(systemName: "plus"),
                           iconColor: .purple,
                           action: .signUp),
            CardDataSource(title: "import_btn_desc".localized,
                           bgGradient: [Color(hex: "#659EAF"), Color(hex: "#88CBE1")],
                           bgImage: Image(componentAsset: "Gradient-Rect")
                               .renderingMode(.original),
                           buttonText: "import_btn_text".localized,
                           icon: Image(systemName: "arrow.forward.to.line"),
                           iconColor: .yellow,
                           action: .signIn),
        ]
        state = EmptyWalletState(dataSource: dataSource)
    }

    func trigger(_ input: EmptyWalletAction) {
        switch input {
        case .signUp:
//            router?
//            router.route(to: )
//            router.coordinator.routeToAuthenticated()
            router?.route(to: \.register)
//            router?.route(to: \.createSecure)
        case .signIn:
            router?.route(to: \.login)
        }
    }
}
