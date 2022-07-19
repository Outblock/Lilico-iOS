//
//  AddCollectionViewModel.swift
//  Lilico
//
//  Created by cat on 2022/6/26.
//

import Foundation

class AddCollectionViewModel: ObservableObject {
    
    @Published var searchQuery = ""

    var liveList: [NFTCollectionItem] {
        if searchQuery.isEmpty {
            return collectionList
        }
        var list: [NFTCollectionItem] = []
        list = collectionList.filter{ item in
            if item.collection.name.localizedCaseInsensitiveContains(searchQuery) {
                return true
            }
            if let des = item.collection.description, des.localizedCaseInsensitiveContains(searchQuery) {
                return true
            }
            return false
        }
        return list
        
    }
    
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
            NFTCollectionItem(collection: it, status: NFTCollectionStateManager.share.isTokenAdded(it.currentAddress()) ? .own : .failed)
        })
        
        await MainActor.run {
            self.searchQuery = ""
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
    
    enum ItemStatus {
        case idle
        case own
        case pending
        case failed
    }
    
    var collection: NFTCollection
    var status: ItemStatus = .idle
    
    func processName() -> String {
        switch status {
            
        case .idle:
            return ""
        case .own:
            return ""
        case .pending:
            return "nft_collection_add_pending".localized
        case .failed:
            return "nft_collection_add_failed".localized
        }
    }
}
