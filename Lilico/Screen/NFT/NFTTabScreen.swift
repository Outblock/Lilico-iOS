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

extension NFTTabScreen {
    
    struct ViewState {
        var collections: [NFTCollection] = []
        var nfts: [NFTModel] = []
        
        var items: [CollectionItem] = []
        
    }
    
    enum Action {
        case search
        case tapNFT
        
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
    @State var selectedIndex = 0
    
    @JSONStorage(key: "favorite")
    var favoriteList: [NFTModel]?
    @State var favoriteId: UUID?
    
    var options = StackTransformViewOptions(
        scaleFactor: 0.10,
        minScale: 0.20,
        maxScale: 0.95,
        maxStackSize: 6,
        spacingFactor: 0.1,
        maxSpacing: nil,
        alphaFactor: 0.00,
        bottomStackAlphaSpeedFactor: 0.90,
        topStackAlphaSpeedFactor: 0.30,
        perspectiveRatio: 0.30,
        shadowEnabled: true,
        shadowColor: Color.LL.rebackground.toUIColor()!,
        shadowOpacity: 0.10,
        shadowOffset: .zero,
        shadowRadius: 5.00,
        stackRotateAngel: 0.00,
        popAngle: 0.31,
        popOffsetRatio: .init(width: -1.45, height: 0.30),
        stackPosition: .init(x: 1.00, y: 0.00),
        reverse: false,
        blurEffectEnabled: false,
        maxBlurEffectRadius: 0.00,
        blurEffectStyle: .light
    )
    
    
    @State private var collectionBarStyle: CollectionBarStyle = .horizontal
    
    /// show the collection by vertical layout
    var onlyShowCollection: Bool {
        return collectionBarStyle == .vertical
    }
    
    var currentLikeNFT: URL?  {
        guard let nft = favoriteList?.first(where: { $0.id == favoriteId
        }) else {
            return nil
        }
        return nft.image
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
            if(currentLikeNFT != nil && isListStyle) {
                VStack {
                    KFImage
                        .url(currentLikeNFT)
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
            
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    VStack(spacing: 0) {
                        topBar
                        favoriteSection
                    }
                    .background(LinearGradient(colors: [.clear, .LL.background],
                                               startPoint: .top, endPoint: .bottom))
                    
                    // Collection
                    collectionBar
                    
                    if (viewModel.items.count > 0) {
                        Section(header: collectionHBody) {
                            if(collectionBarStyle == .horizontal) {
                                nftGrid
                            }
                        }
                        
                    }
                    Spacer()
                }
            }
            .padding(0)
        }
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
    }
    
    var topBar: some View {
        HStack {
            Picker("", selection: $pageStyle) {
                Text("List")
                    .tag(PageStyle.list)
                Text("Grid").tag(PageStyle.grid)
            }
            .pickerStyle(.segmented)
            .frame(width: 112, height: 32, alignment: .leading)
            
            
            Spacer()
            
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
    }
    
    var favoriteSection: some View {
        VStack {
            if((favoriteList?.count ?? 0) > 0) {
                HStack() {
                    Image(systemName: "star.fill")
                    Text("Top Selection")
                        .font(.LL.largeTitle2)
                        .semibold()
                    
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top)
                .foregroundColor(.white)
                
                StackPageView(viewModel.nfts, selection:$favoriteId) { nft in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.LL.background)
                        
                        KFImage
                            .url(nft.image)
                            .fade(duration: 0.25)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .cornerRadius(8)
                            .padding()
                        
                    }
                }
                .options(options)
                .pagePadding(
                    top: .absolute(18),
                    left: .absolute(18),
                    bottom: .absolute(18),
                    right: .fractionalWidth(0.22)
                )
                .frame(width: screenWidth,
                       height: screenHeight * 0.4, alignment: .center)
            }
            
        }
    }
    
    var collectionBar: some View {
        VStack {
            if(isListStyle) {
                HStack() {
                    Image.LL.Logo.collection3D
                    Text("Collections")
                        .font(.LL.largeTitle2)
                        .semibold()
                    
                    Spacer()
                    Button {
                        collectionBarStyle.toggle()
                    } label: {
                        //TODO: add the icon
                        onlyShowCollection ? Image.LL.Logo.gridHLayout : Image.LL.Logo.gridHLayout;
                    }
                    
                }
                .foregroundColor(.LL.text)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .frame(height: isListStyle ? Double.infinity : 0)
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
                            .padding(.leading, 18)
                            
                        })
                        .frame(width: screenWidth,
                               height: 56,
                               alignment: .leading)
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
        GeometryReader { geo in
            
            LazyVGrid(columns: nftLayout, alignment: .center) {
                ForEach(currentNFTs, id: \.self) { nft in
                    NFTSquareCard(nft: nft)
                        .frame(height: ceil((geo.size.width-18*3)/2+50))
                }
            }
            .padding(EdgeInsets(top: 12, leading: 18, bottom: 30, trailing: 18))
            .background(Color.white)
            .cornerRadius(16)
        }
        .padding(.top,12)
        .animation(.easeOut, value: pageStyle)
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
                                    .url(item.collection.logo)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .background(.LL.outline)
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(item.collection.name)
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
                                                item.collection.name == "BoredApeYachtClub" ? 1 : 0)
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
