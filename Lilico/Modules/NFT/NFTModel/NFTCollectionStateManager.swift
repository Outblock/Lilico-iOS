//
//  NFTCollectionStateManager.swift
//  Lilico
//
//  Created by cat on 2022/6/22.
//

import Foundation

final class NFTCollectionState {
    let share = NFTCollectionState()
    private init(){
        //TODO: load cache
    }
    
    private var tokenStateList: [NftCollectionState] = []
    
    func fetch() {
        Task {
            let list = NFTCollectionConfig.share.config
        }
    }
    
}

struct NftCollectionState {
    var name: String
    var address: String
    var isAdded: Bool
    
}
