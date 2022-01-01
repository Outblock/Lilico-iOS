//
//  HomeView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 29/11/21.
//

import SwiftUI

struct HomeView: View {
    
    @AppStorage("selectedTab") var selectedTab: Tab = .wallet
    
    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    switch selectedTab {
                    case .wallet:
//                        WalletView()
//                            .navigationBarHidden(true)
                        EmptyWalletView(viewModel: EmptyWalletViewModel()
                                            .toAnyViewModel())
                    case .explore:
                        OldWalletView()
                    case .profile:
                        ProfileView()
                    }
                }
                .hideNavigationBar()
//                .safeAreaInset(edge: .bottom) {
//                    VStack {}.frame(height: 44)
//                }
                
                InnerCircleTabBar()
//                TabBar()
            }
//            .navigationBarTitle("")
//            .navigationBarHidden(true)
        }
//        .navigationBarTitle("")
//        .navigationBarHidden(true)
//        .hideNavigationBar()
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().colorScheme(.dark)
        HomeView()
    }
}
