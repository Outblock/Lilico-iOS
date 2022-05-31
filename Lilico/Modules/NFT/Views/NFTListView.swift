//
//  NFTListView.swift
//  Lilico
//
//  Created by cat on 2022/5/30.
//

import SwiftUI

struct NFTListView: View {
    
    var list: [NFTModel]
    
    @EnvironmentObject private var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>

    private let nftLayout: [GridItem] = [
        GridItem(.adaptive(minimum: 160)),
        GridItem(.adaptive(minimum: 160))
    ]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: nftLayout, alignment: .center) {
                ForEach(list, id: \.self) { nft in
                    NFTSquareCard(nft: nft, onClick: { model in
                        viewModel.trigger(.info(model))
                    })
                    .frame(height: ceil((screenWidth-18*3)/2+50))
                }
            }
            .padding(EdgeInsets(top: 12, leading: 18, bottom: 30, trailing: 18))
            .cornerRadius(16)
            .background(.LL.Neutrals.background)
            
            VStack{}
                .frame(height: repairHeight() )
                .background(Color.orange)
        }
        
    }
    
    func repairHeight() -> CGFloat {
        if(list.count < 4) {
            return 200.0
        }
        return 0.0
    }
}

struct NFTListView_Previews: PreviewProvider {
    static var previews: some View {
        NFTListView(list: [])
            .environmentObject(NFTTabViewModel())
    }
}
