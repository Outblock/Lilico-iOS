//
//  NFTSquareCard.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import SwiftUI
import Kingfisher

struct NFTSquareCard: View {
    
    var nft: NFTModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                KFImage
                    .url(nft.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.width, alignment: .center)
                    .cornerRadius(8)
                    .clipped()
                Text(nft.name)
                    .font(.LL.body)
                    .semibold()
                    .lineLimit(1)
                
                Text(nft.collections)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .lineLimit(1)
            }
        }
    }
}

struct NFTSquareCard_Previews: PreviewProvider {
    static var previews: some View {
        NFTSquareCard(nft: NFTTabViewModel.testData().state.nfts.first!)
            .frame(width: 160)
    }
}
