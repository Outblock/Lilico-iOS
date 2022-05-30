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
        var favoriteStore: NFTFavoriteStore = NFTFavoriteStore()
        
        var isEmpty: Bool {
            return !loading && items.count == 0
        }
    }
    
    enum Action {
        case search
        case add
        case info(NFTModel)
        case collection(CollectionItem)
        case back
    }
}

struct NFTTabScreen: View {
    @StateObject var themeManager = ThemeManager.shared

    @State var listStyle: NFTTabScreen.ListStyle = .list
    
    var isListStyle: Bool {
        return listStyle == .list
    }
    
    @StateObject
    var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action> 
    
    @State var selectedIndex = 0
    
    @State var favoriteId: String?
    @State var currentNFTImage: URL?
    
    var currentNFTs: [NFTModel] {
        if(listStyle == .list) {
            if(viewModel.state.items.isEmpty) {
                return []
            }
            return viewModel.state.items[selectedIndex].nfts
        }else {
            return viewModel.state.items.flatMap{$0.nfts}
        }
    }
    
    var canShowFavorite: Bool {
        return  (viewModel.favoriteStore.isNotEmpty && isListStyle)
    }
    
    @State private var collectionBarStyle: NFTTabScreen.CollectionBar.BarStyle = .horizontal
    
    /// show the collection by vertical layout
    var onlyShowCollection: Bool {
        return collectionBarStyle == .vertical
    }
    
    let modifier = AnyModifier { request in
        var r = request
        r.setValue("APKAJYJ4EHJ62UVUHINA", forHTTPHeaderField: "CloudFront-Key-Pair-Id")
        return r
    }
    
    
    var body: some View {

        ZStack(alignment: .topLeading) {
            if(viewModel.state.loading) {
                NFTLoading()
            }
            else if(viewModel.state.isEmpty) {
                NFTEmptyView()
            }
            else {
                content
            }
        }
        .preferredColorScheme(themeManager.style)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .environmentObject(viewModel)
    }
    
    var content: some View {
        GeometryReader { geo in
            ZStack() {
                if(canShowFavorite) {
                    NFTBlurImageView(url: currentNFTImage)
                }
                
                if(!viewModel.isEmpty) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(pinnedViews: [.sectionHeaders]) {
                            
                            if(listStyle == .list) {
                                if(canShowFavorite) {
                                    NFTTabScreen.FavoriteView(currentNFTImage: $currentNFTImage)
                                }
                                NFTTabScreen.CollectionBar(barStyle: $collectionBarStyle, listStyle: $listStyle)
                                Section {
                                    if(collectionBarStyle == .horizontal) {
                                        NFTListView(list: currentNFTs)

                                    }
                                } header: {
                                    NFTTabScreen.CollectionBody(barStyle: $collectionBarStyle, selectedIndex: $selectedIndex)
                                }
                            }else {
                                NFTListView(list: currentNFTs)
                            }
                        }
                    }
                    .safeAreaInset(edge: .top) {
                        NFTTabScreen.TopBar(listStyle: $listStyle)
                    }
                    
                    .padding(.top, statusHeight)
                }
            }
            .ignoresSafeArea()
        }
    }
    
    var statusHeight: CGFloat {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        lazy var statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return statusBarHeight
    }
}

extension NFTTabScreen {
    private enum Layout {
        static let menuHeight = 32.0
    }
}

//MARK: FavoriteView
extension NFTTabScreen {
    
    struct FavoriteView: View {
        
        @Binding
        var currentNFTImage: URL?
        
        @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
        
        @State var favoriteId: String?
        
        var body: some View {
            VStack {
                if(viewModel.favoriteStore.favorites.count > 0) {

                    VStack(alignment: .center,spacing: 0) {
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

                        StackPageView(viewModel.favoriteStore.favorites, selection:$favoriteId) { nft in
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
                            .onTapGesture {
                                onTapNFT()
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
//                    .background(LinearGradient(colors: [.LL.background, .clear],
//                                                                   startPoint: .top, endPoint: .bottom))
                    .onChange(of: favoriteId) { id in
                        guard let favoriteId = favoriteId, let nft = viewModel.favoriteStore.find(with: favoriteId) else {
                            let model = viewModel.favoriteStore.favorites.first
                            currentNFTImage = model?.image
                            return
                        }
                        currentNFTImage = nft.image
                    }
                }
            }
            .onAppear {
                if(favoriteId == nil) {
                    favoriteId = viewModel.favoriteStore.favorites.first?.id
                }
            }
        }
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
        
        func onTapNFT() {
            guard let favoriteId = favoriteId, let nft = viewModel.favoriteStore.find(with: favoriteId) else {
                return
            }
            viewModel.trigger(.info(nft))
        }
    }
}

//MARK: TopBar
extension NFTTabScreen {
    
    enum ListStyle: String, CaseIterable, Identifiable {
        case list, grid
        var id: Self { self }
    }
    
    struct TopBar: View {
        @Binding var listStyle: NFTTabScreen.ListStyle
        @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
        
        var body: some View {
            HStack(alignment: .center) {
                if(!viewModel.state.isEmpty) {
                    Picker("", selection: $listStyle) {
                        Text("List")
                            .tag(NFTTabScreen.ListStyle.list)
                        Text("Grid")
                            .tag(NFTTabScreen.ListStyle.grid)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 112,  alignment: .leading)
                }
                Spacer()
                
                if(!viewModel.state.isEmpty) {
                    Button {
                        viewModel.trigger(.search)
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
                    viewModel.trigger(.add)
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
    }
}

//MARK: Collection Bar
extension NFTTabScreen {
    struct CollectionBar: View {
        
        enum BarStyle {
            case horizontal
            case vertical
            
            mutating func toggle() {
                switch self {
                case .horizontal:
                    self = .vertical
                case .vertical:
                    self = .horizontal
                }
            }
        }
        
        @Binding var barStyle: NFTTabScreen.CollectionBar.BarStyle
        @Binding var listStyle: NFTTabScreen.ListStyle
        
        var body: some View {
            VStack {
                if(listStyle == .list) {
                    HStack() {
                        Image(.Image.Logo.collection3D)
                        Text("Collections")
                            .font(.LL.largeTitle2)
                            .semibold()
                        
                        Spacer()
                        Button {
                            barStyle.toggle()
                        } label: {
                            Image((barStyle == .horizontal ? .Image.Logo.gridHLayout : .Image.Logo.gridHLayout))

                        }
                    }
                    .foregroundColor(.LL.text)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }else {
                    HStack{}
                        .frame(height: 0)
                }
            }
            
        }
    }
}

//MARK: Collection Section
extension NFTTabScreen {
    struct CollectionBody: View {
        
        @Binding var barStyle: NFTTabScreen.CollectionBar.BarStyle
        @Binding var selectedIndex: Int
        @EnvironmentObject var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
        
        var body: some View {
            VStack {
                if( barStyle == .horizontal) {
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
                    LazyVStack(alignment: .center, spacing: 12, content: {
                        
                        ForEach(viewModel.state.items, id: \.self) { item in
                            NFTCollectionCard(index: viewModel.state.items.firstIndex(of: item)!, item: item, isHorizontal: false, selectedIndex: $selectedIndex)
                        }
                    })
                    .padding(.horizontal, 18)
                }
            }
            
        }
    }
}


//MARK: Preview
struct NFTTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        NFTTabScreen(viewModel: NFTTabViewModel().toAnyViewModel())
            
    }
}
