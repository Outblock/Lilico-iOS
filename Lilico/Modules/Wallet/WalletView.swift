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

private let ActionViewHeight: CGFloat = 78
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
                    .visibility(state == .waiting ? .gone : .visible)
            }) {
                LazyVStack() {
                    Section(header: headerView) {
                        VStack(spacing: 32) {
                            CardView()
                            actionView
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
                    .listRowInsets(.zero)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.LL.Neutrals.background)
                    .visibility(vm.walletState == .idle ? .visible : .gone)
                }

            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 18)
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

    var actionView: some View {
        VStack{
            HStack() {
                Button {
                    Router.route(to: RouteMap.Wallet.send)
                } label: {
                    VStack(spacing: 6) {
                        Image("wallet-send-stroke")
                            .frame(width: 28, height: 28)
                        Text("send".localized)
                            .foregroundColor(.LL.text)
                            .textCase(.uppercase)
                            .font(.inter(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: ActionViewHeight)
                    .background(.LL.bgForIcon)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                
                Spacer()
                
                Button {
                    Router.route(to: RouteMap.Wallet.receive)
                } label: {
                    VStack(spacing: 6) {
                        Image("wallet-receive-stroke")
                            .frame(width: 28, height: 28)
                        Text("receive".localized)
                            .foregroundColor(.LL.text)
                            .textCase(.uppercase)
                            .font(.inter(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: ActionViewHeight)
                    .background(.LL.bgForIcon)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())

                
                Spacer()
                
                Button {
                    Router.route(to: RouteMap.Wallet.receive)
                } label: {
                    VStack(spacing: 6) {
                        Image("wallet")
                            .frame(width: 28, height: 28)
                        Text("buy".localized)
                            .foregroundColor(.LL.text)
                            .textCase(.uppercase)
                            .font(.inter(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: ActionViewHeight)
                    .background(.LL.bgForIcon)
                    .cornerRadius(12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                
            }
            
            Divider()
                .foregroundColor(.LL.Neutrals.neutrals4)
                .padding(.top, 12)
        }
    }

    var coinSectionView: some View {
        HStack {
            Text("x_coins".localized(vm.coinItems.count))
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
            ZStack {
                VStack {
                    Text(vm.walletName)
                        .foregroundColor(Color(hex: "#FDFBF9"))
                        .font(.inter(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

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
                .padding(18)
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
