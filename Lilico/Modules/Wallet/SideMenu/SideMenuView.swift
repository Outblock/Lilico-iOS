//
//  SideMenuView.swift
//  Lilico
//
//  Created by Selina on 4/1/2023.
//

import SwiftUI

class SideMenuViewModel: ObservableObject {
    
}

struct SideMenuView: View {
    @StateObject private var vm = SideMenuViewModel()
    
    var body: some View {
        VStack {

        }
        .background(Color.LL.orange)
    }
}

class SideContainerViewModel: ObservableObject {
    @Published var isOpen: Bool = false
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onToggle), name: .toggleSideMenu, object: nil)
    }
    
    @objc func onToggle() {
        withAnimation {
            isOpen.toggle()
        }
    }
}

struct SideContainerView: View {
    @StateObject private var vm = SideContainerViewModel()
    private var offset: CGFloat = 65
    
    var body: some View {
        ZStack {
            SideMenuView()
            
            Group {
                makeTabView()
                
                Color.black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        vm.onToggle()
                    }
                    .opacity(vm.isOpen ? 1.0 : 0.0)
            }
            .offset(x: vm.isOpen ? screenWidth - offset : 0)
        }
    }
    
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
}
