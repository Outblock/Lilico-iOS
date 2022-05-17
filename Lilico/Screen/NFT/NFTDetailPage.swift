//
//  NFTDetailPage.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import SwiftUI
import Kingfisher

struct NFTDetailPage: View {
    
    let desc = """
    Monet traveled more extensively than any other Impressionist
    artist in search of new motifs. His journeys to varied places
    including the rugged Normandy coast, the sunny Mediterranean,
    London, the Netherlands, and Norway inspired artworks that
    will be featured in the presentation. This exhibition uncovers
    Monet’s continuous dialogue with nature and its places through
    a thematic and chronological arrangement, from the first
    examples of artworks still indebted to the landscape tradition
    to the revolutionary compositions and series of his late years.
    """
    
    @Binding var nft: NFTModel
    var theColor = Color(hex: 0x6D9987)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                VStack(alignment:.leading) {
                    KFImage
                        .url(nft.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(alignment: .center)
                        .cornerRadius(8)
                        .clipped()
                    
                    HStack(alignment: .center, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(nft.name)
                                .font(.LL.largeTitle3)
                                .foregroundColor(.LL.Neutrals.text)
                                .frame(height: 28)
                            HStack(alignment: .center,spacing: 6) {
                                KFImage
                                    .url(nft.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20,alignment: .center)
                                    .cornerRadius(20)
                                    .clipped()
                                Text(nft.name)
                                    .font(.LL.body)
                                    .foregroundColor(.LL.Neutrals.neutrals4)
                            }
                        }
                        
                        Button {
                            
                        } label: {
                            Image("nft_button_share")
                                .frame(width: 44,height: 44)
                        }
                        .padding(.horizontal,6)
                        
                        Button {
                            
                        } label: {
                            Image("nft_button_star_0")
                                .frame(width: 44,height: 44)
                        }
                        .padding(.horizontal,6)
                        
                    }
                    .padding(.top, 16)
                    .padding(.horizontal,8)
                    
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
                    
                    NFTTagsView(tags: ["School","Main color","Year"], color: theColor)
                    Spacer()
                        .frame(height: 16)
                    Text(desc)
                        .font(Font.inter(size: 14, weight: .light))
                        .foregroundColor(.LL.Neutrals.neutrals6)
                    
                    Spacer()
                        .frame(height: 50)
                }
                .padding(.horizontal,18)
            }
            
            HStack(spacing: 8) {
                Button {
                    
                } label: {
                    Image(systemName: "paperplane")
                        .font(.system(size: 16))
                        .foregroundColor(theColor)
                    Text("Send")
                        .foregroundColor(.LL.Neutrals.text)
                }
                .frame(width: 84, height: 42)
                .background(Color.white)
                
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
                .background(Color.white)
                
                
            }
            .padding(.trailing, 18)

        }
        
        
    }
}

struct NFTDetailPage_Previews: PreviewProvider {
    @State static var nft = NFTTabViewModel.testNFTs().first!
    static var previews: some View {
        NFTDetailPage(nft: $nft)
    }
}


