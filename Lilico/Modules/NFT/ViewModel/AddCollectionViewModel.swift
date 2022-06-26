//
//  AddCollectionViewModel.swift
//  Lilico
//
//  Created by cat on 2022/6/26.
//

import Foundation

class AddCollectionViewModel: ObservableObject {
    
    @Published
    var liveList: [NFTCollectionItem] = []
    
    private var collectionList: [NFTCollectionItem] = []
    
    init() {
        Task {
            await load()
        }
    }
    
    func load() async {
        await NFTCollectionConfig.share.reload()
        await NFTCollectionStateManager.share.fetch()
        collectionList.removeAll { _ in true }
        collectionList = NFTCollectionConfig.share.config.filter({ col in
            !col.currentAddress().isEmpty
        })
        .map({ it in
            NFTCollectionItem(collection: it, isAdded: NFTCollectionStateManager.share.isTokenAdded(it.currentAddress()), isAdding: false)
        })
        
        await MainActor.run {
            liveList.removeAll { _ in
                true
            }
            liveList.append(contentsOf: collectionList)
        }
    }
    
}

extension AddCollectionViewModel {
    func hasTrending() -> Bool {
        //TODO:
        return false
    }
    
}


struct NFTCollectionItem: Hashable {
    var collection: NFTCollection
    var isAdded: Bool
    var isAdding: Bool
}
