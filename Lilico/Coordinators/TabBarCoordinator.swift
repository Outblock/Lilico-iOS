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
        \NewTabBarCoordinator.nft,
        \NewTabBarCoordinator.test,
        \NewTabBarCoordinator.profile,
    ])

    @Route(tabItem: makeHomeTab) var home = makeHome
    @Route(tabItem: makeTestIcon) var nft = makeNFT
    @Route(tabItem: makeTestIcon) var test = makeTest
    @Route(tabItem: makeTestIcon) var profile = makeProfile

    func makeHome() -> NavigationViewCoordinator<HomeCoordinator> {
        return NavigationViewCoordinator(HomeCoordinator())
    }

    @ViewBuilder func makeNFT() -> some View {
        WalletView()
            .hideNavigationBar()
    }

    func makeTest() -> NavigationViewCoordinator<BackupCoordinator> {
        return NavigationViewCoordinator(BackupCoordinator())
    }

    @ViewBuilder func makeProfile() -> some View {
        ProfileView()
            .hideNavigationBar()
    }

    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }

    @ViewBuilder func makeTestIcon(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }

//    @Route
//    var tab = makeHomeTab

    func makeHomeTab() -> NavigationViewCoordinator<HomeCoordinator> {
        NavigationViewCoordinator(HomeCoordinator())
    }
}
