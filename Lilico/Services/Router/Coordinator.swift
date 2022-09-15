//
//  Coordinator.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import Combine
//import Lottie

enum AppTabType {
    case wallet
    case nft
    case explore
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
    
    private lazy var privateView: AppPrivateView = {
        let view = AppPrivateView()
        return view
    }()
    
    private var cancelSets = Set<AnyCancellable>()
    
    init(window: UIWindow) {
        self.window = window
        
        ThemeManager.shared.$style.sink { scheme in
            DispatchQueue.main.async {
                self.refreshColorScheme()
            }
        }.store(in: &cancelSets)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func showRootView() {
        let rootView = makeTabView()
        let hostingView = UIHostingController(rootView: rootView)
        let navi = RouterNavigationController(rootViewController: hostingView)
        navi.setNavigationBarHidden(true, animated: true)
        rootNavi = navi
        window.rootViewController = rootNavi
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            TransactionUIHandler.shared.refreshPanelHolder()
        }
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
        
        let explore = TabBarPageModel<AppTabType>(tag: ExploreTabScreen.tabTag(), iconName: ExploreTabScreen.iconName(), color: ExploreTabScreen.color()) {
            AnyView(ExploreTabScreen())
        }

        let profile = TabBarPageModel<AppTabType>(tag: ProfileView.tabTag(), iconName: ProfileView.iconName(), color: ProfileView.color()) {
            AnyView(ProfileView())
        }

        TabBarView(current: .wallet, pages: [wallet, nft, explore, profile], maxWidth: UIScreen.main.bounds.width)
    }
    
    private func refreshColorScheme() {
        self.window.overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }
}

// MARK: - Private Screen
extension Coordinator {
    @objc private func didEnterBackground() {
        privateView.alpha = 1
        privateView.removeFromSuperview()
        privateView.frame = window.bounds
        window.addSubview(privateView)
        privateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func didBecomeActive() {
        UIView.animate(withDuration: 0.25) {
            self.privateView.alpha = 0
        } completion: { _ in
            self.privateView.removeFromSuperview()
        }
    }
}
