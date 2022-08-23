//
//  NFTCollectionListView.swift
//  Lilico
//
//  Created by cat on 2022/5/30.
//

import Kingfisher
import SwiftUI

class NFTCollectionListViewViewModel: ObservableObject {
    @Published var collection: CollectionItem
    @Published var nfts: [NFTModel]
    
    private var proxy: ScrollViewProxy?
    
    init(collection: CollectionItem) {
        self.collection = collection
        self.nfts = collection.nfts
        
        collection.loadCallback2 = { [weak self] result in
            guard let self = self else {
                return
            }
            
            if result {
                if let proxy = self.proxy {
                    proxy.scrollTo(999, anchor: .bottom)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.nfts = self.collection.nfts
                }
            }
        }
        
        if collection.nfts.isEmpty {
            collection.load()
        }
    }
    
    func loadMoreAction(proxy: ScrollViewProxy) {
        self.proxy = proxy
        collection.load()
    }
}

struct NFTCollectionListView: RouteableView {
    @StateObject var viewModel: NFTTabViewModel
    @StateObject var vm: NFTCollectionListViewViewModel
    
    @State var opacity: Double = 0
    @Namespace var imageEffect
    
    var title: String {
        return ""
    }
    
    var isNavigationBarHidden: Bool {
        return true
    }
    
    init(viewModel: NFTTabViewModel, collection: CollectionItem) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _vm = StateObject(wrappedValue: NFTCollectionListViewViewModel(collection: collection))
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                OffsetScrollViewWithAppBar(title: vm.collection.showName, loadMoreEnabled: true, loadMoreCallback: {
                    if vm.collection.isRequesting || vm.collection.isEnd {
                        return
                    }
                    
                    vm.loadMoreAction(proxy: proxy)
                }, isNoData: vm.collection.isEnd) {
                    Spacer()
                        .frame(height: 64)

                    InfoView(collection: vm.collection)
                        .padding(.bottom, 24)
                    NFTListView(list: vm.nfts, imageEffect: imageEffect)
                        .id(999)
                } appBar: {
                    BackAppBar {
                        viewModel.trigger(.back)
                    }
                }
            }
        }
        .background(
            NFTBlurImageView(colors: viewModel.state.colorsMap[vm.collection.iconURL.absoluteString] ?? [])
                .ignoresSafeArea()
                .offset(y: -4)
        )
        .applyRouteable(self)
        .environmentObject(viewModel)
    }
}

extension NFTCollectionListView {
    struct InfoView: View {
        @EnvironmentObject private var viewModel: NFTTabViewModel

        var collection: CollectionItem

        var body: some View {
            HStack(spacing: 0) {
                KFImage
                    .url(collection.iconURL)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .onSuccess { _ in
                        viewModel.trigger(.fetchColors(collection.iconURL.absoluteString))
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 108, height: 108, alignment: .center)
                    .cornerRadius(12)
                    .clipped()
                    .padding(.leading, 18)
                    .padding(.trailing, 20)

                VStack(alignment: .leading, spacing: 9) {
                    HStack(alignment: .center) {
                        Text(collection.name)
                            .font(.LL.largeTitle3)
                            .fontWeight(.w700)
                            .foregroundColor(.LL.Neutrals.text)
                        Image("Flow")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    .frame(height: 28)

                    Text("x_collections".localized(collection.count))
                        .font(.LL.body)
                        .fontWeight(.w400)
                        .foregroundColor(.LL.Neutrals.neutrals4)
                        .padding(.bottom, 18)
                        .frame(height: 20)

                    HStack(spacing: 8) {
//                        Button {
//
//                        } label: {
//                            Image("nft_button_share_inline")
//                            Text("share".localized)
//                                .font(.LL.body)
//                                .fontWeight(.w600)
//                                .foregroundColor(.LL.Neutrals.neutrals3)
//                        }
//                        .padding(.horizontal, 10)
//                        .frame(height: 38)
//                        .background(.thinMaterial)
//                        .cornerRadius(12)

                        Button {} label: {
                            Image("nft_button_explore")
                            Text("explore".localized)
                                .font(.LL.body)
                                .fontWeight(.w600)
                                .foregroundColor(.LL.Neutrals.neutrals3)
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 38)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                    }
                }
                .background(Color.clear)
                Spacer()
            }
        }
    }
}

struct NFTCollectionListView_Previews: PreviewProvider {
    static var item = NFTTabViewModel.testCollection()

    static var previews: some View {
        NFTCollectionListView(viewModel: NFTTabViewModel(), collection: item)
    }
}
