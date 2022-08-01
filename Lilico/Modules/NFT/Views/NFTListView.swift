//
//  NFTListView.swift
//  Lilico
//
//  Created by cat on 2022/5/30.
//

import SwiftUI
import Kingfisher

struct NFTListView: View {
    var list: [NFTModel]
    var imageEffect: Namespace.ID

    @EnvironmentObject private var viewModel: NFTTabViewModel

    private let nftLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 130), spacing: 18),
        GridItem(.adaptive(minimum: 130), spacing: 18),
    ]

    var body: some View {
        VStack {
            LazyVGrid(columns: nftLayout, alignment: .center) {
                ForEach(list, id: \.self) { nft in
                    
                    
                    ContextMenuPreview {
                        NFTSquareCard(nft: nft, imageEffect: imageEffect) { model in
                            viewModel.trigger(.info(model))
                        }
                        .frame(height: ceil((screenWidth - 18 * 3) / 2 + 50))
                    } preview: {
                        KFImage
                            .url(nft.image)
                            .placeholder({
                                Image("placeholder")
                                    .resizable()
                            })
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } menu: {
                        let isFavorite =  NFTFavoriteStore.shared.isFavorite(with: nft)
                        let imageName = isFavorite ? "nft_btn_selection_s" : "nft_btn_selection";
                        let like = UIAction(title: "top_selection".localized, image: UIImage(named: imageName)) { _ in
                            if isFavorite {
                                NFTFavoriteStore.shared.removeFavorite(nft)
                            }else {
                                NFTFavoriteStore.shared.addFavorite(nft)
                            }
                        }
                        
                        let share = UIAction(title: "share".localized, image: UIImage(named: "nft_btn_share")) { _ in
                            //TODO: share action
                        }
                        
                        let send = UIAction(title: "send".localized, image: UIImage(named: "nft_btn_send")) { _ in
                            //TODO: send NFT
                        }
                        
                        return UIMenu(title: "", children: [like, share,send])
                    } onEnd: {
                        
                    }
                }
            }
            .padding(EdgeInsets(top: 12, leading: 18, bottom: 30, trailing: 18))
        }
        .background(
            Color.LL.Shades.front
        )
        .cornerRadius(16)
    }

    func repairHeight() -> CGFloat {
        if list.count < 4 {
            return 200.0
        }
        return 0.0
    }
}

struct NFTListView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        NFTListView(list: [], imageEffect: namespace)
            .environmentObject(NFTTabViewModel())
    }
}
