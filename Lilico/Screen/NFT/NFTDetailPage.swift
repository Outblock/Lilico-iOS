//
//  NFTDetailPage.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import SwiftUI
import Kingfisher

struct NFTDetailPage: View {
    
    @Binding var nft: NFTModel
    
    var body: some View {
        ZStack() {
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
                Spacer()
            }
            .padding(.horizontal,18)
        }
    }
}

struct NFTDetailPage_Previews: PreviewProvider {
    @State static var nft = NFTTabViewModel.testNFTs().first!
    static var previews: some View {
        NFTDetailPage(nft: $nft)
    }
}
