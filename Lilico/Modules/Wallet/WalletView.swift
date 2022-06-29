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
import Stinsen

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
//        WalletView.CoinCell()
    }
}

private let ActionViewHeight: CGFloat = 76
private let CardViewHeight: CGFloat = 214
private let CoinCellHeight: CGFloat = 73
private let CoinIconHeight: CGFloat = 43

struct WalletView: View {
    @StateObject var themeManager = ThemeManager.shared
    @StateObject private var vm = WalletViewModel()
    @EnvironmentObject private var router: WalletCoordinator.Router

    init() {
        UICollectionView.appearance().backgroundColor = .clear
    }

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

    var body: some View {
        emptyView
            .visibility(vm.walletState == .noAddress ? .visible : .gone)
        
        List {
            Section {
                VStack(spacing: 32) {
                    headerView
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
                    CoinCell(coin: coin)
                }
            }
            .listRowInsets(.zero)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.LL.Neutrals.background)
            .visibility(vm.walletState == .idle ? .visible : .gone)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 18)
        .backgroundFill(.LL.Neutrals.background)
        .environmentObject(vm)
        .visibility(vm.walletState != .noAddress ? .visible : .gone)
        .preferredColorScheme(themeManager.style)
    }

    var headerView: some View {
        HStack {
            Text("wallet".localized)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 24, weight: .bold))

            Spacer()

            Image("icon-wallet-scan").renderingMode(.template).foregroundColor(.primary)
        }
    }

    var actionView: some View {
        HStack {
            Button {} label: {
                VStack(spacing: 7) {
                    Image("icon-wallet-send")
                    Text("send".localized)
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 12, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            Button {} label: {
                VStack(spacing: 7) {
                    Image("icon-wallet-receive")
                    Text("receive".localized)
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 12, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Spacer()

            Button {} label: {
                VStack(spacing: 7) {
                    Image("icon-wallet-buy")
                    Text("buy".localized)
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 12, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .frame(height: ActionViewHeight)
        .background(.LL.Shades.front)
        .cornerRadius(16)
    }

    var coinSectionView: some View {
        HStack {
            Text("x_coins".localized(vm.coinItems.count))
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 18, weight: .bold))

            Spacer()

            Button {
                router.route(to: \.addToken)
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
                    Image("bg-wallet-card")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: CoinIconHeight, height: CoinIconHeight)
                    .background(.LL.Neutrals.note)
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
