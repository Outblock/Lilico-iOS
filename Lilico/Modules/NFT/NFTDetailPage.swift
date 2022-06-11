//
//  NFTDetailPage.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import SwiftUI
import Kingfisher

struct NFTDetailPage: View {
    
    
    @StateObject
    var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    
    var nft: NFTModel
    
    @State var opacity: Double = 0
    
    var theColor: Color {
        if let color = viewModel.state.colorsMap[nft.image.absoluteString]?.first {
            return color
        }
        return Color.LL.Primary.salmonPrimary
    }
    
    @State
    private var isSharePresented: Bool = false

    @State
    private var items:[UIImage] = []
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            ScrollView(showsIndicators: false) {
                Spacer()
                    .frame(height: 64)
                VStack(alignment:.leading) {
                    VStack(spacing: 0){
                        KFImage
                            .url(nft.image)
                            .onSuccess({ result in
                                fetchColor()
                            })
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(alignment: .center)
                            .cornerRadius(8)
                            .padding(.horizontal, 18)
                            .clipped()
                            
                        
                        HStack(alignment: .center, spacing: 0) {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(nft.collections)
                                    .font(.LL.largeTitle3)
                                    .fontWeight(.w700)
                                    .foregroundColor(.LL.Neutrals.text)
                                    .frame(height: 28)
                                HStack(alignment: .center,spacing: 6) {
                                    KFImage
                                        .url(nft.logoUrl)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 20, height: 20,alignment: .center)
                                        .cornerRadius(20)
                                        .clipped()
                                    Text(nft.name)
                                        .font(.LL.body)
                                        .fontWeight(.w400)
                                        .foregroundColor(.LL.Neutrals.neutrals4)
                                }
                            }
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image("nft_button_share")
                                    .frame(width: 44,height: 44)
                                    .foregroundColor(theColor)
                            }
                            .padding(.horizontal,6)
                            .sheet(isPresented: $isSharePresented) {
                                
                            } content: {
                                ShareSheet(items: $items)
                            }


                            
                            Button {
                                if(viewModel.favoriteStore.isFavorite(with: nft)) {
                                    viewModel.favoriteStore.removeFavorite(nft)
                                }else {
                                    viewModel.favoriteStore.addFavorite(nft)
                                }
                            } label: {
                                ZStack(alignment: .center){
                                    if(viewModel.favoriteStore.isFavorite(with: nft)) {
                                        Image("nft_logo_circle_fill")
                                        Image("nft_logo_star_fill")
                                            .frame(width: 20, height:20)
                                            .foregroundColor(Color.white)
                                    }else {
                                        Image("nft_logo_circle")
                                        Image("nft_logo_star")
                                            .frame(width: 20, height:20)
                                    }
                                }
                                .frame(width: 44, height: 44)
                                .foregroundColor(theColor)
                                
                            }
                            .padding(.horizontal,6)
                            
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 26)
                    }
                    
                    
                    //
                    VStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: 18) {
                            if(!nft.tags.isEmpty) {
                                NFTTagsView(tags: nft.tags, color: theColor)
                            }
                            
                            Text(nft.declare)
                                .font(Font.inter(size: 14, weight: .w400))
                                .foregroundColor(.LL.Neutrals.neutrals6)
                        }
                        .padding(.horizontal, 26)
                        .padding(.vertical, 18)
                    }
                    .background(
                        Color.LL.Shades.front
                            .opacity(0.32)
                    )
                    .shadow(color: .LL.Shades.front, radius: 16, x: 0, y: 8)
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    
                    
                    
                    Spacer()
                        .frame(height: 50)
                }
                
            }
            
            HStack(spacing: 8) {
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "paperplane")
                            .font(.system(size: 16))
                            .foregroundColor(theColor)
                        Text("Send")
                            .foregroundColor(.LL.Neutrals.text)
                    }
                    
                    
                }
                .frame(width: 84, height: 42)
                .background(
                    Color.LL.Neutrals.background
                )
                .cornerRadius(12)
                .shadow(color: theColor.opacity(0.4), radius: 24, x: 0, y: 16)
                
                
                Menu {
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16))
                            .foregroundColor(theColor)
                        Text("Download")
                            .foregroundColor(.LL.Neutrals.text)
                    }

                    Button {
                        
                    } label: {
                        HStack {
                            Text("View on web")
                                .foregroundColor(.LL.Neutrals.text)
                            Image(systemName: "globe.asia.australia")
                                .font(.system(size: 16))
                                .foregroundColor(theColor)
                            
                        }
                        
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(theColor)
                    Text("More")
                        .foregroundColor(.LL.Neutrals.text)
                }
                .frame(width: 84, height: 42)
                .background(
                    Color.LL.Neutrals.background
                )
                .cornerRadius(12)
                .shadow(color: theColor.opacity(0.4), radius: 24, x: 0, y: 16)
                
                
            }
            .padding(.trailing, 18)

        }
        .background(
            NFTBlurImageView(colors: viewModel.state.colorsMap[nft.image.absoluteString] ?? [])
                .ignoresSafeArea()
                .offset(y: -4)
        )
        .overlay(
            NFTNavigationBar(title: nft.name, opacity: $opacity) {
                viewModel.trigger(.back)
            }
        )
        
        
    }
    
    var date: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading,spacing: 0) {
                    Text("Purchase Price")
                        .font(.LL.body)
                        .frame(height: 22)
                        .foregroundColor(.LL.Neutrals.neutrals7)
                    HStack(alignment:.center,spacing: 4) {
                        Image("Flow")
                            .resizable()
                            .frame(width: 12, height: 12)
                        Text("1,289.20")
                            .font(Font.W700(size: 16))
                            .foregroundColor(.LL.Neutrals.text)
                            .frame(height: 24)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {
                    Text("Purchase Date")
                        .font(.LL.body)
                        .frame(height: 22)
                        .foregroundColor(.LL.Neutrals.neutrals7)
                    Text("2022.01.22")
                        .font(Font.W700(size: 16))
                        .foregroundColor(.LL.Neutrals.text)
                        .frame(height: 24)
                }
            }
            .padding(0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal,8)
    }
    
    func fetchColor() {
        viewModel.trigger(.fetchColors(nft.image.absoluteString))
    }
    
}

struct NFTDetailPage_Previews: PreviewProvider {
    static var nft = NFTTabViewModel.testNFT()
    static var previews: some View {
        NFTDetailPage(viewModel: NFTTabViewModel().toAnyViewModel(), nft: nft)
    }
}


