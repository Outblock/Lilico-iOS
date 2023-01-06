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
        nftCount = LocalUserDefaults.shared.nftCount
        
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
    @StateObject private var wm = WalletManager.shared
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack {
                    cardView
                    scanView
                        .padding(.top, 24)
                    addressListView
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
        VStack(spacing: 0) {
            if let mainnetAddress = wm.getFlowNetworkTypeAddress(network: .mainnet) {
                Button {
                    if LocalUserDefaults.shared.flowNetwork != .mainnet {
                        LocalUserDefaults.shared.flowNetwork = .mainnet
                    }
                    
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .mainnet, address: mainnetAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .mainnet)
                }
            }
            
            if let testnetAddress = wm.getFlowNetworkTypeAddress(network: .testnet) {
                Button {
                    if LocalUserDefaults.shared.flowNetwork != .testnet {
                        LocalUserDefaults.shared.flowNetwork = .testnet
                    }
                    
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .testnet, address: testnetAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .testnet)
                }
            }
            
            if let sandboxAddress = wm.getFlowNetworkTypeAddress(network: .sandboxnet) {
                Button {
                    if LocalUserDefaults.shared.flowNetwork != .sandboxnet {
                        LocalUserDefaults.shared.flowNetwork = .sandboxnet
                    }
                    
                    NotificationCenter.default.post(name: .toggleSideMenu)
                } label: {
                    addressCell(type: .sandboxnet, address: sandboxAddress, isSelected: LocalUserDefaults.shared.flowNetwork == .sandboxnet)
                }
            }
        }
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(12)
    }
    
    func addressCell(type: LocalUserDefaults.FlowNetworkType, address: String, isSelected: Bool) -> some View {
        HStack(spacing: 15) {
            Image("flow")
                .resizable()
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("My Wallet")
                        .foregroundColor(Color.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .semibold))
                    
                    Text(type.rawValue)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .foregroundColor(type.color)
                        .font(.inter(size: 10, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .circular)
                                .fill(type.color.opacity(0.2))
                        )
                        .visibility(type == .mainnet ? .gone : .visible)
                }
                .frame(alignment: .leading)
                
                Text(address)
                    .foregroundColor(Color.LL.Neutrals.text3)
                    .font(.inter(size: 12))
            }
            .frame(alignment: .leading)
            
            Spacer()
            
            Image("icon-checkmark")
                .visibility(isSelected ? .visible : .gone)
        }
        .padding(.horizontal, 18)
        .frame(height: 70)
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
