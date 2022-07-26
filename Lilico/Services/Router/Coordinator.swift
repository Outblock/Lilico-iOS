//
//  Coordinator.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI

enum AppTabType {
    case wallet
    case nft
    case profile
}

protocol AppTabBarPageProtocol {
    static func tabTag() -> AppTabType
    static func iconName() -> String
    static func color() -> Color
}

final class Coordinator {
    let window: UIWindow
    lazy var rootNavi: UINavigationController? = nil
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showRootView() {
        let rootView = makeTabView()
        let hostingView = UIHostingController(rootView: rootView)
        let navi = UINavigationController(rootViewController: hostingView)
        navi.setNavigationBarHidden(true, animated: true)
        rootNavi = navi
        window.rootViewController = rootNavi
    }
}

extension Coordinator {
    @ViewBuilder private func makeTabView() -> some View {
        let wallet = TabBarPageModel<AppTabType>(tag: WalletView.tabTag(), iconName: WalletView.iconName(), color: WalletView.color()) {
            AnyView(WalletView())
        }

        let nft = TabBarPageModel<AppTabType>(tag: NFTCoordinator.tabTag(), iconName: NFTCoordinator.iconName(), color: NFTCoordinator.color()) {
            AnyView(WalletView())
        }

        let profile = TabBarPageModel<AppTabType>(tag: ProfileCoordinator.tabTag(), iconName: ProfileCoordinator.iconName(), color: ProfileCoordinator.color()) {
            AnyView(WalletView())
        }

        TabBarView(current: .wallet, pages: [wallet, nft, profile], maxWidth: UIScreen.main.bounds.width)
    }
}
