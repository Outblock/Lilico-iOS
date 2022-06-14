//
//  NFTListView.swift
//  Lilico
//
//  Created by cat on 2022/5/30.
//

import SwiftUI

struct NFTListView: View {
    
    var list: [NFTModel]
    var imageEffect: Namespace.ID
    
    @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>

    private let nftLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 130), spacing: 18),
        GridItem(.adaptive(minimum: 130), spacing: 18)
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: nftLayout, alignment: .center) {
                ForEach(list, id: \.self) { nft in
                    
                    NFTSquareCard(nft: nft, imageEffect: imageEffect) { model in
                        viewModel.trigger(.info(model))
                    }
                    .frame(height: ceil((screenWidth-18*3)/2+50))
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
        if(list.count < 4) {
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
