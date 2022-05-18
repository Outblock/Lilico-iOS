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
        \NewTabBarCoordinator.discover,
        \NewTabBarCoordinator.profile,
    ])

    @Route(tabItem: makeHomeTab) var home = makeHome
    @Route(tabItem: makeTestIcon) var nft = makeNFT
    @Route(tabItem: makeTestIcon) var discover = makeDiscover
    @Route(tabItem: makeTestIcon) var profile = makeProfile

    func makeHome() -> HomeCoordinator {
        return HomeCoordinator()
    }

    @ViewBuilder func makeNFT() -> some View {
        WalletView()
            .hideNavigationBar()
    }

    @ViewBuilder func makeDiscover() -> some View {
//        VStack {
//            ScenekitView()
//            Text("")
//                .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.5, alignment: .bottom)
//        }
//        .background{
//            NewEmptyWalletBackgroundView(image: Image("Asset2"), color: Color(hex: "#00EF8B"))
//        }
//        .clipped()
//        .edgesIgnoringSafeArea(.top)
//        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        
        NFTTabScreen(viewModel: NFTTabViewModel().toAnyViewModel())
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
