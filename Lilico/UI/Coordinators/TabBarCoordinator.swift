//
//  TabCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 24/12/21.
//

import SwiftUI

final class NewTabBarCoordinator: TabCoordinatable {
    var child = TabChild(startingItems: [
        \NewTabBarCoordinator.home,
        \NewTabBarCoordinator.wallet,
        \NewTabBarCoordinator.nft,
        \NewTabBarCoordinator.profile,
    ])

    @Route(tabItem: makeHomeTab) var home = makeHome
    @Route(tabItem: makeTestIcon) var wallet = makeWallet
    @Route(tabItem: makeTestIcon) var nft = makeNFT
    @Route(tabItem: makeTestIcon) var discover = makeDiscover
    @Route(tabItem: makeTestIcon) var profile = makeProfile

    func makeHome() -> HomeCoordinator {
        return HomeCoordinator()
    }

    @ViewBuilder func makeWallet() -> some View {
        WalletView()
            .hideNavigationBar()
    }
    
    func makeNFT() -> NFTCoordinator {
        return NFTCoordinator()
    }

    func makeDiscover() -> NFTCoordinator {
        return NFTCoordinator()
    }

    func makeProfile() -> ProfileCoordinator {
        return ProfileCoordinator()
        
//        let model = ProfileViewModel()
//
//        ProfileView()
//            .hideNavigationBar().environmentObject(model)
    }

    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }

    @ViewBuilder func makeTestIcon(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }
}
