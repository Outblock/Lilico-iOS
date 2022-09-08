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
                        .aspectRatio(CGSize(width: 339, height: 92), contentMode: .fit)
                    
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
                        Button {
                            
                            let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
                                feedbackGenerator.impactOccurred()
                            
                            //TODO: Open Browser
                            let url = URL(string: "https://fcl-harness-eight.vercel.app/")!
                            
                            Router.route(to: RouteMap.Explore.browser(url))
                            
//                            if LocalUserDefaults.shared.flowNetwork == .testnet,
//                                let url = dApp.testnetURL {
//                                Router.route(to: RouteMap.Explore.browser(url))
//                            } else {
//                                Router.route(to: RouteMap.Explore.browser(dApp.url))
//                            }
                            
    
                            
                        } label: {
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
                                    HStack {
                                        Text(dApp.name)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .foregroundColor(.LL.text)
                                        
                                        Spacer()
                                        
                                        Text(dApp.category.uppercased())
                                            .font(.LL.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.LL.outline.opacity(0.2))
                                            .foregroundColor(Color.LL.Neutrals.neutrals9)
                                            .cornerRadius(20)
                                    }
                                    
                                    Text(dApp.host ?? "")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(.LL.Neutrals.note)
                                        .font(.LL.footnote)
                                    
                                    Spacer(minLength: 5)
                                    
                                    Text(dApp.description)
                                        .font(.LL.footnote)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(.LL.Neutrals.neutrals7)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(10)
                            .padding(.vertical, 5)
                            .background(Color.LL.bgForIcon)
                            .cornerRadius(16)
                        }
                        .buttonStyle(ScaleButtonStyle())
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
        .onChange(of: LocalUserDefaults.shared.flowNetwork, perform: { _ in
            vm.trigger(.fetchList)
        })
        .background(
            Color.LL.Neutrals.background.ignoresSafeArea()
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarHidden(true)
    }
}

struct ExploreTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabScreen()
    }
}
