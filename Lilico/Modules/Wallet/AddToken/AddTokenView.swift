//
//  AddTokenView.swift
//  Lilico
//
//  Created by Selina on 27/6/2022.
//

import SwiftUI
import Kingfisher

//struct AddTokenView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTokenView.AddTokenConfirmView(token: nil)
//    }
//}


struct AddTokenView: View {
    @StateObject var vm = AddTokenViewModel()
    @EnvironmentObject private var router: WalletCoordinator.Router
    
    var body: some View {
        ZStack {
            listView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("add_token".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .customBottomSheet(isPresented: $vm.confirmSheetIsPresented, title: "add_token".localized, background: { Color.LL.Neutrals.background }) {
            AddTokenConfirmView(token: vm.pendingActiveToken)
        }
        .environmentObject(vm)
        .disabled(vm.isRequesting)
    }
    
    var listView: some View {
        IndexedList(vm.searchResults) { section in
            Section {
                ForEach(section.tokenList) { token in
                    TokenItemCell(token: token, isActivated: token.isActivated, action: {
                        vm.willActiveTokenAction(token)
                    })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .buttonStyle(.plain)
            } header: {
                sectionHeader(section)
                    .id(section.id)
            }
            .listRowInsets(EdgeInsets(top: 6, leading: 18, bottom: 6, trailing: 27))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .listStyle(.plain)
        .background(Color.LL.deepBg)
        .searchable(text: $vm.searchText)
    }
    
    @ViewBuilder private func sectionHeader(_ section: AddTokenViewModel.Section) -> some View {
        let sectionName = section.sectionName
        Text(sectionName == "#" ? "\(sectionName)" : "#\(sectionName)")
            .foregroundColor(.LL.Neutrals.neutrals8)
            .font(.inter(size: 18, weight: .semibold))
    }
}

private let TokenIconWidth: CGFloat = 32
private let TokenCellHeight: CGFloat = 52

extension AddTokenView {
    struct TokenItemCell: View {
        let token: TokenModel
        let isActivated: Bool
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack {
                    KFImage.url(token.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: TokenIconWidth, height: TokenIconWidth)
                        .background(.LL.Neutrals.note)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(token.name)
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .semibold))
                        
                        
                        Text(token.symbol?.uppercased() ?? "")
                            .foregroundColor(.LL.Neutrals.note)
                            .font(.inter(size: 12, weight: .medium))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if isActivated {
                        Image(systemName: .checkmarkSelected).foregroundColor(.LL.Success.success3)
                    } else {
                        Image(systemName: .add).foregroundColor(.LL.Primary.salmonPrimary)
                    }
                }
                .padding(.horizontal, 11)
                .frame(height: TokenCellHeight)
                .background({
                    Color.LL.Neutrals.background.cornerRadius(16)
                })
            }
        }
    }
}

extension AddTokenView {
    struct AddTokenConfirmView: View {
        @EnvironmentObject var vm: AddTokenViewModel
        let token: TokenModel?
        
        var body: some View {
            VStack {
                ZStack {
                    ZStack(alignment: .top) {
                        Color.LL.Primary.salmon5
                            .frame(maxWidth: .infinity)
                            .frame(height: 188)
                            .cornerRadius(16)
                        
                        Text(token?.name ?? "Token Name")
                            .foregroundColor(.LL.Button.light)
                            .font(.inter(size: 18, weight: .bold))
                            .padding(.horizontal, 40)
                            .frame(height: 45)
                            .background(Color(hex: "#1A1A1A"))
                            .cornerRadius([.bottomLeft, .bottomRight], 16)
                    }
                    
                    KFImage
                        .url(token?.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 114, height: 114)
                        .background(.LL.Neutrals.note)
                        .clipShape(Circle())
                        .padding(.top, 45)
                }
                
                Button {
                    if let token = token {
                        vm.confirmActiveTokenAction(token)
                    }
                } label: {
                    HStack(spacing: 5) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .visibility(vm.isRequesting ? .visible : .gone)
                        
                        Text("enable".localized)
                            .foregroundColor(.LL.Button.light)
                            .font(.inter(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.LL.Primary.salmonPrimary)
                    .cornerRadius(16)
                    .opacity(vm.isRequesting ? 0.8 : 1)
                }
                .padding(.top, 66)
                .padding(.bottom, 20 + UIView.bottomSafeAreaHeight)
                .disabled(vm.isRequesting)
            }
            .padding(.top, 48)
            .padding(.horizontal, 36)
        }
    }
}
