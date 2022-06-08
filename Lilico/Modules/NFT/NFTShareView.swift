//
//  NFTShareView.swift
//  Lilico
//
//  Created by cat on 2022/6/6.
//

import SwiftUI
import Kingfisher

struct NFTShareView: View {
    var nft: NFTModel
    var name: String = "ZYANZ"
    
    var mainColor = Color(hex: 0x6D9987)
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                KFImage
                    .url(nft.logoUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20,alignment: .center)
                    .cornerRadius(20)
                    .clipped()
                    .padding(.trailing, 6)
                    
                Text("FROM \(name.uppercased())")
                    .font(.LL.body)
                    .fontWeight(.w700)
                    .foregroundColor(.LL.Shades.front)
                Spacer()
                Text("@\(name)")
                    .font(.LL.body)
                    .fontWeight(.w700)
                    .foregroundColor(.LL.Shades.front)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(mainColor)
            .cornerRadius(12)
            .clipped()
            
            
            VStack(alignment: .leading) {
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
                
                
                
                KFImage
                    .url(nft.image)
                    .onSuccess({ result in
//                        color(from: result.image)
                    })
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(alignment: .center)
                    .cornerRadius(8)
                    .padding(.top, 24)
                    .clipped()
                    
            }
            .cornerRadius(16)
            .background(Color.LL.background.opacity(0.48))
            
            
            HDashLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .foregroundColor(mainColor.opacity(0.18))

            
            HStack(spacing: 0) {
                VStack(alignment: .leading,spacing: 0) {
                    //TODO: app logo
                    Image("")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24,alignment: .center)
                        .cornerRadius(4)
                        .clipped()
                    VStack(alignment: .leading) {
                        Text("Shared via".uppercased())
                            .font(.LL.miniTitle)
                            .fontWeight(.w600)
                            .foregroundColor(.LL.Neutrals.note)
                        HStack(spacing: 4) {
                            Text("Lilico".uppercased())
                                .font(.LL.miniTitle)
                                .fontWeight(Font.Weight.w600)
                                .foregroundColor(.LL.Neutrals.note)
                            HStack{}
                                .frame(width: 7, height: 3)
                                .cornerRadius(4)
                                .background(Color.LL.Primary.salmonPrimary)
                        }
                    }
                }
                Spacer()
                Image("")
                    .frame(width: 64, height: 64)
                    .cornerRadius(4)
            }
            .padding(.vertical,12)
            .cornerRadius(16)
            
        }
        .padding(18)
    }
}

struct NFTShareView_Previews: PreviewProvider {
    static var previews: some View {
        NFTShareView(nft: NFTTabViewModel.testNFT())
    }
}



