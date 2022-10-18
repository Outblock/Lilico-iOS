//
//  WalletView.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import FirebaseAuth
import Flow
import Kingfisher
import SPConfetti
import SwiftUI
import SwiftUIX

private let ActionViewHeight: CGFloat = 54
private let CardViewHeight: CGFloat = 214
private let CoinCellHeight: CGFloat = 73
private let CoinIconHeight: CGFloat = 43

extension WalletView: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .wallet
    }

    static func iconName() -> String {
        "CoinHover"
    }

    static func color() -> Color {
        return .LL.Primary.salmonPrimary
    }
}

struct WalletView: View {
    @StateObject var um = UserManager.shared
    @StateObject private var vm = WalletViewModel()
    @State var isRefreshing: Bool = false

    var emptyView: some View {
        Text("no address")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundFill(.LL.Neutrals.background)
    }

    var loadingView: some View {
        Text("loading")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundFill(.LL.Neutrals.background)
    }

    var errorView: some View {
        Text("error")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundFill(.LL.Neutrals.background)
    }
    
    /// user is not logged in UI
    var guestView: some View {
        EmptyWalletView()
    }
    
    /// user logged in UI
    var normalView: some View {
        ZStack {
            emptyView
                .visibility(vm.walletState == .noAddress ? .visible : .gone)
            
            VStack(spacing: 10) {
                
                headerView
                    .padding(.horizontal, 18)
                
                RefreshableScrollView(showsIndicators: false, onRefresh: { done in
                    if isRefreshing {
                        return
                    }
                    
                    isRefreshing = true
                    vm.reloadWalletData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        done()
                        isRefreshing = false
                    }
                }, progress: { state in
                    ImageAnimated(imageSize: CGSize(width: 60, height: 60), imageNames: ImageAnimated.appRefreshImageNames(), duration: 1.6, isAnimating: state == .loading || state == .primed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .transition(AnyTransition.move(edge: .top).combined(with: .scale).combined(with: .opacity))
                        .visibility(state == .waiting ? .gone : .visible)
                        .zIndex(10)
                }) {
                    LazyVStack {
                        Spacer(minLength: 10)
                        Section {
                            VStack(spacing: 12) {
                                CardView()
                                    .zIndex(11)
                                actionView
                                    .padding(.horizontal, 18)
                            }
                            
                            loadingView
                                .visibility(vm.walletState == .loading ? .visible : .gone)
                            errorView
                                .visibility(vm.walletState == .error ? .visible : .gone)
                        }
                        .listRowInsets(.zero)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.LL.Neutrals.background)
                        
                        Section {
                            coinSectionView
                            ForEach(vm.coinItems, id: \.token.symbol) { coin in
                                Button {
                                    Router.route(to: RouteMap.Wallet.tokenDetail(coin.token))
                                } label: {
                                    CoinCell(coin: coin)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(ScaleButtonStyle())
                                
                            }
                        }
                        .padding(.horizontal, 18)
                        .listRowInsets(.zero)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.LL.Neutrals.background)
                        .visibility(vm.walletState == .idle ? .visible : .gone)
                    }
                    
                }
                .listStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .backgroundFill(.LL.Neutrals.background)
            .environmentObject(vm)
            .visibility(vm.walletState != .noAddress ? .visible : .gone)
        }
    }

    var body: some View {
        ZStack {
            guestView.visibility(um.isLoggedIn ? .gone : .visible)
            normalView.visibility(um.isLoggedIn ? .visible : .gone)
        }
        .navigationBarHidden(true)
    }

    var headerView: some View {
        HStack {
            Text("wallet".localized)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 24, weight: .bold))

            Spacer()

            Button {
                vm.scanAction()
            } label: {
                Image("icon-wallet-scan").renderingMode(.template).foregroundColor(.primary)
            }
        }
    }

    func actionButton(imageName: String, action: @escaping () -> ()) -> some View {
        return Button {
            action()
        } label: {
            VStack(spacing: 6) {
                Image(imageName)
                    .frame(width: 28, height: 28)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: ActionViewHeight)
            .background(.LL.bgForIcon)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    var actionView: some View {
        VStack{
            HStack() {
                actionButton(imageName: "wallet-send-stroke") {
                    Router.route(to: RouteMap.Wallet.send())
                }
                Spacer()
                actionButton(imageName: "wallet-receive-stroke") {
                    Router.route(to: RouteMap.Wallet.receive)
                }
                
                if RemoteConfigManager.shared.config.features.onRamp ?? false == true {
                    Spacer()
                    actionButton(imageName: "wallet") {
                        Router.route(to: RouteMap.Wallet.buyCrypto)
                    }
                }
                
//                Spacer()
//                actionButton(imageName: "wallet-swap-stroke") {
//                    Router.route(to: RouteMap.Wallet.swap(nil))
//                }
            }
            Divider()
                .foregroundColor(.LL.Neutrals.neutrals4)
                .padding(.top, 12)
        }
    }

    var coinSectionView: some View {
        HStack {
            Text(vm.coinItems.count == 1 ? "x_coin".localized(vm.coinItems.count) : "x_coins".localized(vm.coinItems.count))
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 18, weight: .bold))

            Spacer()

            Button {
                Router.route(to: RouteMap.Wallet.addToken)
            } label: {
                Image("icon-wallet-coin-add")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.neutrals1)
            }

        }
        .buttonStyle(.plain)
        .padding(.top, 32)
    }
}

extension WalletView {
    struct CardView: View {
        @EnvironmentObject var vm: WalletViewModel

        @AppStorage("WalletCardBackrgound")
        private var walletCardBackrgound: String = "fade:0"
        
        var body: some View {
            VStack(spacing: 0) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .fill(Color.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: CardViewHeight)
                        .padding(.horizontal, 18)
//                        .padding(3)
//                        .padding(.horizontal, 24)
                        .shadow(color: CardBackground(value: walletCardBackrgound).color.opacity(0.1),
                                radius: 20, x: 0, y: 8)
                    
                    cardView
                        .padding(.horizontal, 18)
                }
                
                Button {
                    Router.route(to: RouteMap.Wallet.transactionList(nil))
                } label: {
                    transactionView
                        .padding(.horizontal, 18)
                }
                .zIndex(-1)
            }
        }
        
        var transactionView: some View {
            HStack(spacing: 7) {
                Text("wallet_transactions".localized)
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(.LL.Other.text2)
                
                Spacer()
                
                Text("\(vm.transactionCount)")
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(.LL.Other.text1)
                    .frame(height: 24)
                    .padding(.horizontal, 6)
                    .background(Color.LL.Other.bg1)
                    .cornerRadius(12)
                    .visibility(vm.transactionCount == 0 ? .gone : .visible)
                
                Image("icon-account-arrow-right")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Other.icon1)
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .frame(height: 64)
            .background(.LL.Other.bg2)
            .cornerRadius(12)
            .padding(.horizontal, 6)
            .padding(.top, -12)
        }
        
        var cardView: some View {
            ZStack {
                VStack {
                    HStack {
                        Text(vm.walletName)
                            .foregroundColor(Color(hex: "#FDFBF9"))
                            .font(.inter(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Text(UserManager.shared.isMeowDomainEnabled ? UserManager.shared.userInfo?.meowDomain ?? "" : "")
                            .foregroundColor(Color(hex: "#FDFBF9"))
                            .font(.inter(size: 14, weight: .semibold))
                    }

                    Spacer()

                    Text(vm.isHidden ? "****" : "$ \(vm.balance.currencyString)")
                        .foregroundColor(.white)
                        .font(.inter(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer()

                    HStack(spacing: 8) {
                        Text(vm.isHidden ? "******************" : vm.address)
                            .foregroundColor(Color(hex: "#FDFBF9"))
                            .font(.inter(size: 15, weight: .bold))
                                                
                        Button {
                            vm.copyAddressAction()
                        } label: {
                            Image("icon-address-copy")
                                .frame(width: 25, height: 25)
                        }

                        Spacer()

                        Button {
                            vm.toggleHiddenStatusAction()
                        } label: {
                            Image(vm.isHidden ? "icon-wallet-hidden-on" : "icon-wallet-hidden-off")
                        }
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 24)
                .background {                    
                    CardBackground(value: walletCardBackrgound).renderView()
                }
                .cornerRadius(16)
            }
            .frame(height: CardViewHeight)
            .buttonStyle(.plain)
        }
    }

    struct CoinCell: View {
        let coin: WalletViewModel.WalletCoinItemModel
        @EnvironmentObject var vm: WalletViewModel

        var body: some View {
            HStack(spacing: 9) {
                KFImage.url(coin.token.icon)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: CoinIconHeight, height: CoinIconHeight)
                    .clipShape(Circle())

                VStack(spacing: 7) {
                    HStack {
                        Text(coin.token.name)
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 15, weight: .medium))

                        Spacer()

                        Text("\(vm.isHidden ? "****" : coin.balance.currencyString) \(coin.token.symbol?.uppercased() ?? "?")")
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 12, weight: .medium))
                    }

                    HStack {
                        Text("$\(coin.last.currencyString)")
                            .foregroundColor(.LL.Neutrals.neutrals8)
                            .font(.inter(size: 12, weight: .medium))

                        Text(coin.changeString)
                            .foregroundColor(coin.changeColor)
                            .font(.inter(size: 11, weight: .medium))

                        Spacer()

                        Text(vm.isHidden ? "****" : "$\(coin.balanceAsUSD)")
                            .foregroundColor(.LL.Neutrals.neutrals8)
                            .font(.inter(size: 12, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: CoinCellHeight)
        }
    }
}

// MARK: - Helper

private struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
