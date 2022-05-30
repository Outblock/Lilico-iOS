//
//  NewTabCoor.swift
//  Lilico
//
//  Created by Selina on 27/5/2022.
//

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

final class TabBarCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<TabBarCoordinator>
    
    private let walletView = WalletCoordinator().view()
    private let nftView = NFTCoordinator().view()
    private let profileView = ProfileCoordinator().view()
    
    @Root var start = makeTabView
    
    init() {
        stack = NavigationStack(initial: \TabBarCoordinator.start)
    }
    
    @ViewBuilder func makeTabView() -> some View {
        let wallet = TabBarPageModel<AppTabType>(tag: WalletCoordinator.tabTag(), iconName: WalletCoordinator.iconName(), color: WalletCoordinator.color()) {
            self.walletView
        }
        
        let nft = TabBarPageModel<AppTabType>(tag: NFTCoordinator.tabTag(), iconName: NFTCoordinator.iconName(), color: NFTCoordinator.color()) {
            self.nftView
        }
        
        let profile = TabBarPageModel<AppTabType>(tag: ProfileCoordinator.tabTag(), iconName: ProfileCoordinator.iconName(), color: ProfileCoordinator.color()) {
            self.profileView
        }
        
        TabBarView(current: .wallet, pages: [wallet, nft, profile], maxWidth: UIScreen.main.bounds.width)
    }
}
