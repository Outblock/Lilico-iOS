//
//  ExploreTabScreen.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import SwiftUI
import Kingfisher
import SwiftUIX

extension ExploreTabScreen: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .explore
    }
    
    static func iconName() -> String {
        "Category"
    }
    
    static func color() -> SwiftUI.Color {
        return .LL.Secondary.violetDiscover
    }
}

struct ExploreTabScreen: View {
    
    @StateObject private var vm = ExploreTabViewModel()
    
    @State var text: String = ""
    
    var body: some View {
        
        ZStack {
            ScrollView {
                Section {
                    HStack {
                        SearchBar(text: $text, purpose: "Test", iconColor: .LL.Secondary.violet4)
                    }
                }.padding(12)
                
                LazyVStack(spacing: 18) {
                    
                    Image("meow_banner")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 92)
                    
                    HStack {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.LL.caption)
                        Text("dApps")
                            .bold()
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("All")
                                .font(.LL.footnote)
                                .foregroundColor(.LL.Secondary.violetDiscover)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.LL.Secondary.violet4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(vm.state.list, id: \.name) { dApp in
                        HStack(alignment: .top) {
                            KFImage
                                .url(dApp.logo)
                                .placeholder({
                                    Image("placeholder")
                                        .resizable()
                                })
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44, alignment: .center)
                                .cornerRadius(22)
                                .clipped()
                                .padding(.leading, 8)
                                .padding(.trailing, 16)
                            VStack(alignment: .leading) {
                                Text(dApp.name)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.LL.text)
                                
                                Text(dApp.url.host ?? "")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.LL.text)
                                
                                Spacer(minLength: 5)
                                
                                Text(dApp.description)
                                    .font(.LL.footnote)
                                    .lineLimit(2)
                                    .foregroundColor(.LL.Neutrals.neutrals7)
                            }
                        }
                        .padding(10)
                        .background(Color.LL.deepBg)
                        .cornerRadius(16)
                    }
                }
                .background(.LL.Neutrals.background)
                .padding(.bottom, 18)
                .padding(.horizontal, 18)
            }
            .background(.LL.Neutrals.background)
            .listStyle(.plain)
        }
        .task {
            vm.trigger(.fetchList)
        }
        .background(.LL.Neutrals.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ExploreTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabScreen()
    }
}
