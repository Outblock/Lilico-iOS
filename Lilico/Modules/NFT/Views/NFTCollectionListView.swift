//
//  NFTCollectionListView.swift
//  Lilico
//
//  Created by cat on 2022/5/30.
//

import SwiftUI
import Kingfisher

struct NFTCollectionListView: View {
    
    var collection: CollectionItem
    
    @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    @State var opacity: Double = 0
    
    init(collection: CollectionItem) {
        self.collection = collection
    }
    
    var body: some View {
        
        ZStack {
            ScrollView(showsIndicators: false) {
                Spacer()
                    .frame(height: 64)
                
                InfoView(collection: collection)
                    .padding(.bottom, 24)
                NFTListView(list: collection.nfts)
            }
        }
        .background(
            
            NFTBlurImageView(colors: viewModel.state.colorsMap[collection.iconURL.absoluteString] ?? [])
                .ignoresSafeArea()
                .offset(y: -4)
        )
        .overlay(
            NFTNavigationBar(title: collection.showName, opacity: $opacity) {
                viewModel.trigger(.back)
            }
        )
    }
}

extension NFTCollectionListView {
    struct InfoView: View {
        
        @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>

        var collection: CollectionItem
        
        var body: some View {
            HStack(spacing: 0) {
                KFImage
                    .url(collection.iconURL)
                    .onSuccess({ result in
                        viewModel.trigger(.fetchColors(collection.iconURL.absoluteString))
                    })
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
                    
                    Text("\(collection.count) Collections")
                        .font(.LL.body)
                        .fontWeight(.w400)
                        .foregroundColor(.LL.Neutrals.neutrals4)
                        .padding(.bottom, 18)
                        .frame(height: 20)
                    
                    HStack(spacing: 8) {
                        Button {
                            
                        } label: {
                            Image("nft_button_share_inline")
                            Text("Share")
                                .font(.LL.body)
                                .fontWeight(.w600)
                                .foregroundColor(.LL.Neutrals.neutrals3)
                        }
                        .padding(.horizontal, 10)
                        .frame(height: 38)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        

                        Button {
                            
                        } label: {
                            Image("nft_button_explore")
                            Text("Explore")
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
    
    static var item  = NFTTabViewModel.testCollection()
    
    static var previews: some View {
        
        NFTCollectionListView(collection: item)
            .environmentObject(NFTTabViewModel().toAnyViewModel())
    }
}
