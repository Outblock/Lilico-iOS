//
//  SideMenuView.swift
//  Lilico
//
//  Created by Selina on 4/1/2023.
//

import SwiftUI
import Kingfisher
import Combine

private let SideOffset: CGFloat = 65

class SideMenuViewModel: ObservableObject {
    @Published var nftCount: Int = 0
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .nftCountChanged).sink { [weak self] noti in
            DispatchQueue.main.async {
                self?.nftCount = LocalUserDefaults.shared.nftCount
            }
        }.store(in: &cancelSets)
    }
    
    func scanAction() {
        NotificationCenter.default.post(name: .toggleSideMenu)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ScanHandler.scan()
        }
    }
}

struct SideMenuView: View {
    @StateObject private var vm = SideMenuViewModel()
    @StateObject private var um = UserManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack {
                    cardView
                    scanView
                        .padding(.top, 24)
                }
                .padding(.horizontal, 12)
                .padding(.top, 25)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.LL.background)
            
            // placeholder, do not use this
            VStack {
                
            }
            .frame(width: SideOffset)
            .frame(maxHeight: .infinity)
        }
    }
    
    var cardView: some View {
        VStack(alignment: .leading, spacing: 0) {
            KFImage.url(URL(string: um.userInfo?.avatar.convertedAvatarString() ?? ""))
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .cornerRadius(36)
                .offset(y: -20)
            
            Text(um.userInfo?.nickname ?? "Lilico")
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 24, weight: .semibold))
                .padding(.top, 10)
                .padding(.bottom, 5)
            
            Text("Since 2022 · \(vm.nftCount) NFTs")
                .foregroundColor(.LL.Neutrals.text3)
                .font(.inter(size: 14))
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.LL.Neutrals.neutrals6
                .cornerRadius(12)
        }
    }
    
    var scanView: some View {
        Button {
            vm.scanAction()
        } label: {
            HStack {
                Image("scan-stroke")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("scan".localized)
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .semibold))
                
                Spacer()
                
                Image("icon-right-arrow-1")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text)
            }
            .padding(.horizontal, 20)
            .frame(height: 48)
            .background(Color.LL.Neutrals.neutrals6)
            .cornerRadius(12)
        }
    }
    
    var addressListView: some View {
        
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
    
    var body: some View {
        ZStack {
            SideMenuView()
                .offset(x: vm.isOpen ? 0 : -(screenWidth - SideOffset))
            
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
            .offset(x: vm.isOpen ? screenWidth - SideOffset : 0)
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
