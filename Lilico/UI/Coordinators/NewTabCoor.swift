//
//  NewTabCoor.swift
//  Lilico
//
//  Created by Selina on 27/5/2022.
//

import SwiftUI

enum AppTabType {
    case home
    case wallet
    case nft
    case profile
}

protocol AppTabBarPageProtocol {
    static func tabTag() -> AppTabType
    static func iconName() -> String
    static func color() -> Color
}

final class TabBarCoor: NavigationCoordinatable {
    let stack: NavigationStack<TabBarCoor>
    var homeC = HomeCoordinator()
    var nftC = NFTCoordinator()
    var profileC = ProfileCoordinator()
    
    @Root var start = makeTabView
    
    init() {
        stack = NavigationStack(initial: \TabBarCoor.start)
    }
    
    @ViewBuilder func makeTabView() -> some View {
        let home = TabBarPageModel<AppTabType>(tag: HomeCoordinator.tabTag(), iconName: HomeCoordinator.iconName(), color: HomeCoordinator.color()) {
            self.homeC.view()
        }
        
        let nft = TabBarPageModel<AppTabType>(tag: NFTCoordinator.tabTag(), iconName: NFTCoordinator.iconName(), color: NFTCoordinator.color()) {
            self.nftC.view()
        }
        
        let profile = TabBarPageModel<AppTabType>(tag: ProfileCoordinator.tabTag(), iconName: ProfileCoordinator.iconName(), color: ProfileCoordinator.color()) {
            self.profileC.view()
        }
        
        TabBarView(current: .home, pages: [home, nft, profile], maxWidth: 390)
    }
}
