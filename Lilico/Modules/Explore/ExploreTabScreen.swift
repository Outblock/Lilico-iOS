//
//  ExploreTabScreen.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import SwiftUI
import Kingfisher
import SwiftUIX
import FancyScrollView

private let BookmarkCellWidth: CGFloat = 56

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
    
    var bookmarkColumns: [GridItem] = Array(repeating: .init(.fixed(BookmarkCellWidth), spacing: 14), count: 5)
    
    var header: some View {
        Button {
            Router.route(to: RouteMap.Explore.searchExplore)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.LL.bgForIcon)
                    .frame(height: 52)
                
                HStack(alignment: .center, spacing: 12) {
                    
                    Image("icon-search")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Secondary.violet4)
                        .frame(width: 24, height: 24)
                    
                    Text("Search name or URL")
                        .font(.inter(size: 16, weight: .semibold))
                        .foregroundColor(.LL.Secondary.violet4)
                    
                    Spacer()
                    
                    Button {
                        ScanHandler.scan()
                    } label: {
                        Image("btn-scan")
                            .renderingMode(.template)
                            .foregroundColor(.LL.Secondary.violet4)
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
            }
        }
        .padding(.horizontal, 16)
    }
    
    var body: some View {
        
        VStack(spacing: 12) {
            header
                .shadow(color: Color.LL.Secondary.violet4.opacity(0.2),
                        radius: 12, x: 0, y: 8)
            
            if vm.state.list.isEmpty {
                Spacer()
                ExploreEmptyScreen()
                    .background(.LL.Neutrals.background)
                Spacer()
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 18) {
                        
                        
                        //                        Image("meow_banner")
                        //                            .resizable()
                        //                            .frame(maxWidth: .infinity)
                        //                            .aspectRatio(CGSize(width: 339, height: 92), contentMode: .fit)
                        
                        
                        
                        VStack(spacing: 18) {
                            bookmarkHeader
                            bookmarkGrid
                        }
                        .visibility(vm.webBookmarkList.isEmpty ? .gone : .visible)
                        
                        dAppHeader
                        dappList
                        
                    }
                    .background(.LL.Neutrals.background)
                    .padding(.bottom, 18)
                    .padding(.horizontal, 18)
                }
                .background(.LL.Neutrals.background)
                .listStyle(.plain)
            }
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
    
    var dAppHeader: some View {
        HStack {
            Image(systemName: "square.grid.2x2.fill")
                .font(.LL.caption)
            Text("List")
                .bold()
            Spacer()
            //                        Button {
            //
            //                        } label: {
            //                            Text("All")
            //                                .font(.LL.footnote)
            //                                .foregroundColor(.LL.Secondary.violetDiscover)
            //                            Image(systemName: "arrow.right")
            //                                .foregroundColor(.LL.Secondary.violet4)
            //                        }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var dappList : some View {
        
        ForEach(vm.state.list, id: \.name) { dApp in
            Button {
                
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
                feedbackGenerator.impactOccurred()
                
                //       let url = URL(string: "https://fcl-harness-eight.vercel.app/")!
                //                            Router.route(to: RouteMap.Explore.browser(url))
                
                if LocalUserDefaults.shared.flowNetwork == .testnet,
                   let url = dApp.testnetURL {
                    Router.route(to: RouteMap.Explore.browser(url))
                } else {
                    Router.route(to: RouteMap.Explore.browser(dApp.url))
                }
                
                
                
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
                        
                        //                                    Text(dApp.host ?? "")
                        //                                        .frame(maxWidth: .infinity, alignment: .leading)
                        //                                        .foregroundColor(.LL.Neutrals.note)
                        //                                        .font(.LL.footnote)
                        
                        //                                    Spacer(minLength: 5)
                        
                        Text(dApp.description + "\n")
                            .font(.LL.footnote)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.LL.Neutrals.neutrals7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.trailing, 12)
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
}

extension ExploreTabScreen {
    var bookmarkHeader: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .font(.LL.caption)
            Text("browser_bookmark".localized)
                .bold()
            
            Spacer()
            
            Button {
                Router.route(to: RouteMap.Explore.bookmark)
            } label: {
                HStack(spacing: 5) {
                    Text("browser_bookmark_view".localized)
                        .font(.inter(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#7D7AFF"))
                    
                    Image("icon-search-arrow")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 11)
                        .foregroundColor(Color(hex: "#C2C3F2"))
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    var bookmarkGrid: some View {
        LazyVGrid(columns: bookmarkColumns, alignment: .center, spacing: 16) {
            ForEach(vm.webBookmarkList, id: \.id) { bookmark in
                createBookmarkItemView(bookmark: bookmark)
            }
        }
    }
    
    func createBookmarkItemView(bookmark: WebBookmark) -> some View {
        Button {
            if let url = URL(string: bookmark.url) {
                Router.route(to: RouteMap.Explore.browser(url))
            }
        } label: {
            KFImage.url(bookmark.url.toFavIcon())
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: BookmarkCellWidth, height: BookmarkCellWidth)
                .clipShape(Circle())
        }
    }
}

struct ExploreTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabScreen()
    }
}
