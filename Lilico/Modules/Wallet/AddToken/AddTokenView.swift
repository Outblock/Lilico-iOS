//
//  AddTokenView.swift
//  Lilico
//
//  Created by Selina on 27/6/2022.
//

import SwiftUI
import Kingfisher

struct AddTokenView_Previews: PreviewProvider {
    static var previews: some View {
        AddTokenView()
    }
}


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
    }
    
    var listView: some View {
        IndexedList(vm.searchResults) { section in
            Section {
                ForEach(section.tokenList) { token in
                    TokenItemCell(token: token)
                        .listRowSeparator(.hidden)
                        .background(Color.clear)
                }
            } header: {
                sectionHeader(section)
                    .id(section.id)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .listStyle(.plain)
            .background(Color.LL.deepBg)
            .searchable(text: $vm.searchText)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 7))
        }
    }
    
    @ViewBuilder private func sectionHeader(_ section: AddTokenViewModel.Section) -> some View {
        let sectionName = section.sectionName
        Text(sectionName == "#" ? "\(sectionName)" : "#\(sectionName)")
            .foregroundColor(.LL.Neutrals.neutrals8)
            .font(.inter(size: 18, weight: .semibold))
            .padding(.top, 16)
    }
}

private let TokenIconWidth: CGFloat = 32
private let TokenCellHeight: CGFloat = 52

extension AddTokenView {
    struct TokenItemCell: View {
        let token: TokenModel
        
        var body: some View {
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
                
                if token.isActivated {
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
