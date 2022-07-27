//
//  Coordinator.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import Combine

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
    
    private var cancelSets = Set<AnyCancellable>()
    
    init(window: UIWindow) {
        self.window = window
        
        ThemeManager.shared.$style.sink { scheme in
            DispatchQueue.main.async {
                self.refreshColorScheme()
            }
        }.store(in: &cancelSets)
    }
    
    func showRootView() {
        let rootView = makeTabView()
        let hostingView = UIHostingController(rootView: rootView)
        let navi = RouterNavigationController(rootViewController: hostingView)
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

        let nft = TabBarPageModel<AppTabType>(tag: NFTTabScreen.tabTag(), iconName: NFTTabScreen.iconName(), color: NFTTabScreen.color()) {
            AnyView(NFTTabScreen())
        }

        let profile = TabBarPageModel<AppTabType>(tag: ProfileView.tabTag(), iconName: ProfileView.iconName(), color: ProfileView.color()) {
            AnyView(ProfileView())
        }

        TabBarView(current: .wallet, pages: [wallet, nft, profile], maxWidth: UIScreen.main.bounds.width)
    }
    
    private func refreshColorScheme() {
        self.window.overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }
}
