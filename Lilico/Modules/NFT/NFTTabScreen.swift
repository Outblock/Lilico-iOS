//
//  NFTTabScreen.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import SwiftUI
// Make sure you added this dependency to your project
// More info at https://bit.ly/CVPagingLayout
import CollectionViewPagingLayout
import Kingfisher
import WebKit

extension NFTTabScreen {
    
    struct ViewState {
        var loading: Bool = true
        var items: [CollectionItem] = []
        
        
        var isEmpty: Bool {
            return !loading && items.count == 0
        }
    }
    
    enum Action {
        case search
        case info(NFTModel, NFTFavoriteStore)
    }
}

struct NFTTabScreen: View {

    private enum PageStyle:String, CaseIterable, Identifiable {
        case list, grid
        var id: Self { self }
    }
    
    @State private var pageStyle: PageStyle = .list
    var isListStyle: Bool {
        return pageStyle == .list
    }
    
    @StateObject
    var favoriteStore: NFTFavoriteStore = NFTFavoriteStore()
    
    private enum CollectionBarStyle {
        case horizontal
        case vertical
        
        internal mutating func toggle() {
            switch self {
            case .horizontal:
                self = .vertical
            case .vertical:
                self = .horizontal
            }
        }
    }
    
    @StateObject
    var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    
    @State
    var selectedIndex = 0
    
    @State var favoriteId: String?
    var currentNFTImage: URL? {
        guard let favoriteId = favoriteId, let nft = favoriteStore.find(with: favoriteId) else {
            let model = favoriteStore.favorites.first
            return model?.image
        }
        return nft.image
    }
    
    @State private var collectionBarStyle: CollectionBarStyle = .horizontal
    
    /// show the collection by vertical layout
    var onlyShowCollection: Bool {
        return collectionBarStyle == .vertical
    }
    
    var canShowFavorite: Bool {
        return favoriteStore.isNotEmpty && isListStyle
    }
    
    var currentNFTs: [NFTModel] {
        if(isListStyle) {
            return viewModel.state.items[selectedIndex].nfts
        }else {
            return viewModel.state.items.flatMap{$0.nfts}
        }
    }
    
    let modifier = AnyModifier { request in
        var r = request
        r.setValue("APKAJYJ4EHJ62UVUHINA", forHTTPHeaderField: "CloudFront-Key-Pair-Id")
        return r
    }
    
    var nftLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160))
    ]
    
    
    var body: some View {
        ZStack {
            if(viewModel.state.loading) {
                NFTLoading()
            }else if(viewModel.state.isEmpty) {
                NFTEmptyView()
            }else {
                ZStack(alignment: .topLeading) {
                    
                    if( canShowFavorite ) {
                        VStack {
                            KFImage
                                .url(currentNFTImage)
                                .fade(duration: 0.25)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: screenWidth,
                                       height: screenHeight * 0.6,
                                       alignment: .topLeading)
                            
                            Spacer()
                        }
                        .blur(radius: 30, opaque: true)
                        .mask(
                            LinearGradient(gradient: Gradient(colors:
                                                                [Color.black, Color.clear]), startPoint: .top, endPoint: .center)
                        )
                        .edgesIgnoringSafeArea(.top)
                    }
                    
                    VStack {
                        topBar
                        ScrollView(showsIndicators: false) {
                            
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                
                                if(canShowFavorite) {
                                    NFTFavoriteView(favoriteId: $favoriteId, favoriteNFTs: favoriteStore.favorites) {
                                        let nft = favoriteStore.find(with: favoriteId!)!
                                        viewModel.trigger(.info(nft, favoriteStore))
                                    }
                                }
                                collectionBar
                                
                                if (viewModel.items.count > 0) {
                                    Section(header: collectionHBody) {
                                        if(collectionBarStyle == .horizontal || !isListStyle) {
                                            nftGrid
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 44)
                .background(Color.LL.background, ignoresSafeAreaEdges: .all)
            }
        }
        .environmentObject(NFTFavoriteStore())
    }
    
    var topBar: some View {
        HStack {
            if(!viewModel.state.isEmpty) {
                Picker("", selection: $pageStyle) {
                    Text("List")
                        .tag(PageStyle.list)
                    Text("Grid").tag(PageStyle.grid)
                }
                .pickerStyle(.segmented)
                .frame(width: 112, height: 32, alignment: .leading)
            }
            
            Spacer()
            if(!viewModel.state.isEmpty) {
                Button {
                    
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .padding(8)
                        .background {
                            Circle()
                                .foregroundColor(.LL.outline.opacity(0.8))
                        }
                }
            }
            
            
            Button {
                
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding(8)
                    .background {
                        Circle()
                            .foregroundColor(.LL.outline.opacity(0.8))
                    }
            }
        }
        .padding(.horizontal, 18)
        .background(Color.clear)
    }
    
    
    var collectionBar: some View {
        VStack {
            if(isListStyle) {
                HStack() {
                    Image(.Image.Logo.collection3D)
                    Text("Collections")
                        .font(.LL.largeTitle2)
                        .semibold()
                    
                    Spacer()
                    Button {
                        collectionBarStyle.toggle()
                    } label: {
                        //TODO: add the icon
                        onlyShowCollection ? Image(.Image.Logo.gridHLayout) : Image(.Image.Logo.gridHLayout);
                                                                                       }   
                }
                .foregroundColor(.LL.text)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .animation(.easeIn, value: pageStyle)
        
    }
    
    var collectionHBody: some View {
        VStack {
            if(isListStyle) {
                Group {
                    if( collectionBarStyle == .horizontal) {
                        ScrollView(.horizontal,
                                   showsIndicators: false,
                                   content: {
                            
                            LazyHStack(alignment: .center, spacing: 12, content: {
                                
                                ForEach(viewModel.state.items, id: \.self) { item in
                                    NFTCollectionCard(index: viewModel.state.items.firstIndex(of: item)!, item: item, isHorizontal: true, selectedIndex: $selectedIndex)
                                }
                            })
                            .frame(height: 56)
                            .padding(.leading, 18)
                            .padding(.bottom, 12)
                            
                        })
                    }else {
                        ScrollView(.vertical,
                                   showsIndicators: false,
                                   content: {
                            
                            LazyVStack(alignment: .center, spacing: 12, content: {
                                
                                ForEach(viewModel.state.items, id: \.self) { item in
                                    NFTCollectionCard(index: viewModel.state.items.firstIndex(of: item)!, item: item, isHorizontal: false, selectedIndex: $selectedIndex)
                                }
                            })
                            .padding(.horizontal, 18)
                            
                        })
                    }
                }
            }
        }
        .animation(.easeOut, value: pageStyle)
        
    }
    
    
    var nftGrid: some View {
        LazyVGrid(columns: nftLayout, alignment: .center) {
            ForEach(currentNFTs, id: \.self) { nft in
                NFTSquareCard(nft: nft, onClick: { model in
                    viewModel.trigger(.info(model, favoriteStore))
                })
                .frame(height: ceil((screenWidth-18*3)/2+50))
            }
        }
        .padding(EdgeInsets(top: 12, leading: 18, bottom: 30, trailing: 18))
        .cornerRadius(16)
        .background(Color.white)
        .animation(.easeOut, value: pageStyle)
    }
}

extension NFTTabScreen {
    private enum Layout {
        static let menuHeight = 32.0
    }
}


struct CollectionHeader: View {
    
    @Binding var index: Int
    
    var list: [CollectionItem]
    
    
    var body: some View {
        VStack {
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                LazyHStack(alignment: .center, spacing: 10, content: {
                    Text("  ")
                    ForEach(list, id: \.self) { item in
                        
                        Button {
                            index = list.firstIndex(of: item) ?? 0
                        } label: {
                            
                            HStack {
                                KFImage
                                    .url(item.iconURL)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .background(.LL.outline)
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(item.showName)
                                            .font(.LL.body)
                                            .bold()
                                            .foregroundColor(.LL.neutrals1)
                                        
                                        Image("Flow")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                    }
                                    
                                    Text("\(item.count) Collections")
                                        .font(.LL.body)
                                        .foregroundColor(.LL.note)
                                }
                            }
                            .padding(8)
                            .background(.LL.frontColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.LL.text,
                                            lineWidth:
                                                item.showName == "BoredApeYachtClub" ? 1 : 0)
                            )
                            .shadow(color: .LL.rebackground.opacity(0.05),
                                    radius: 8, x: 0, y: 0)
                            
                        }
                    }
                    Text("  ")
                })
                    .padding(.vertical, 12)
            })
                .frame(width: screenWidth,
                       height: 56 + 24,
                       alignment: .leading)
        }
        .background(.LL.background)
    }
}



struct NFTTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        NFTTabScreen(viewModel: NFTTabViewModel.testData().toAnyViewModel())
            .colorScheme(.light)
    }
}
