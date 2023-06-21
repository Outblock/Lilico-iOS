//
//  AccountSettingView.swift
//  Lilico
//
//  Created by Selina on 21/6/2023.
//

import SwiftUI
import Combine
import Kingfisher

class AccountSettingViewModel: ObservableObject {
    init() {
        ChildAccountManager.shared.refresh()
    }
}

struct AccountSettingView: RouteableView {
    @StateObject private var cm = ChildAccountManager.shared
    @StateObject private var vm = AccountSettingViewModel()
    
    var title: String {
        "wallet".localized.capitalized
    }
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    walletInfoCell()
                    
                    if !cm.childAccounts.isEmpty {
                        linkAccountContentView
                            .padding(.top, 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 18)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
    }
    
    func walletInfoCell() -> some View {
        Button {
            Router.route(to: RouteMap.Profile.walletSetting(true))
        } label: {
            HStack(spacing: 18) {
                Image("flow")
                    .resizable()
                    .frame(width: 36, height: 36)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("My Wallet")
                        .foregroundColor(Color.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .semibold))
                    
                    Text(WalletManager.shared.getPrimaryWalletAddress() ?? "0x")
                        .foregroundColor(Color.LL.Neutrals.text3)
                        .font(.inter(size: 12))
                }
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(height: 78)
            .background(Color.LL.background)
            .contentShape(Rectangle())
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), x: 0, y: 12, blur: 16)
        }
    }
    
    var linkAccountContentView: some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            Text("linked_account".localized)
                .foregroundColor(Color.LL.Neutrals.text4)
                .font(.inter(size: 16, weight: .bold))
            
            ForEach(cm.sortedChildAccounts, id: \.address) { childAccount in
                Button {
                    Router.route(to: RouteMap.Profile.accountDetail(childAccount))
                } label: {
                    childAccountCell(childAccount)
                }
            }
        }
    }
    
    func childAccountCell(_ childAccount: ChildAccount) -> some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 18) {
                KFImage.url(URL(string: childAccount.icon))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(childAccount.name)
                        .foregroundColor(Color.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .semibold))
                    
                    Text(childAccount.address)
                        .foregroundColor(Color.LL.Neutrals.text3)
                        .font(.inter(size: 12))
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Button {
                withAnimation(.none) {
                    cm.togglePinStatus(childAccount)
                }
            } label: {
                Image("icon-pin")
                    .renderingMode(.template)
                    .foregroundColor(childAccount.isPinned ? Color.LL.Primary.salmonPrimary : Color(hex: "#E6E6E6"))
                    .frame(width: 32, height: 32)
                    .background(childAccount.isPinned ? Color(hex: "#FC814A").opacity(0.15) : Color.clear)
                    .contentShape(Rectangle())
            }
        }
        .padding(.leading, 20)
        .frame(height: 66)
        .background(Color.LL.background)
        .contentShape(Rectangle())
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), x: 0, y: 12, blur: 16)
    }
}
