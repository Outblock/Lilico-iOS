//
//  NFTUIKitListDataSource.swift
//  Lilico
//
//  Created by Selina on 15/8/2022.
//

import UIKit

class NFTUIKitListGridDataModel {
    // TODO: Use real address
    private var owner: String = "0x01d63aa89238a559"
    var nfts: [NFTModel] = []
    var isEnd: Bool = false
    var isRequesting: Bool = false
    
    init() {
        if let cachedNFTs = NFTUIKitCache.cache.getGridNFTs() {
            let models = cachedNFTs.map { NFTModel($0, in: nil) }
            self.nfts = models
        }
    }
    
    func requestGridAction(offset: Int) async throws {
        if isRequesting {
            return
        }
        
        isRequesting = true
        
        let limit = 24
        let nfts = try await requestGrid(offset: offset, limit: limit)
        DispatchQueue.syncOnMain {
            if offset == 0 {
                self.nfts.removeAll()
            }

            self.appendGridNFTsNoDuplicated(nfts)
            self.isEnd = nfts.count < limit
            self.isRequesting = false
            self.saveToCache()
        }
    }
    
    private func requestGrid(offset: Int, limit: Int = 24) async throws -> [NFTModel] {
        let request = NFTGridDetailListRequest(address: owner, offset: offset, limit: limit)
        let response: Network.Response<NFTListResponse> = try await Network.requestWithRawModel(LilicoAPI.NFT.gridDetailList(request))
        
        guard let nfts = response.data?.nfts else {
            return []
        }
        
        let models = nfts.map { NFTModel($0, in: nil) }
        return models
    }
    
    private func appendGridNFTsNoDuplicated(_ newNFTs: [NFTModel]) {
        for nft in newNFTs {
            let exist = nfts.first { $0.id == nft.id }
            
            if exist == nil {
                nfts.append(nft)
            }
        }
    }
    
    private func saveToCache() {
        let array = nfts.map { $0.response }
        NFTUIKitCache.cache.saveGridToCache(array)
    }
}

class NFTUIKitListNormalDataModel {
    // TODO: Use real address
    private var owner: String = "0x01d63aa89238a559"
    var items: [CollectionItem] = []
    var selectedIndex = 0
    var isRequesting: Bool = false
    var isCollectionListStyle: Bool = false
    
    var favNFTs: [NFTModel] = []
    
    init() {
        if var cachedCollections = NFTUIKitCache.cache.getCollections() {
            cachedCollections.sort {
                if $0.count == $1.count {
                    return $0.collection.contractName < $1.collection.contractName
                }
                
                return $0.count > $1.count
            }
            
            var items = [CollectionItem]()
            for collection in cachedCollections {
                let item = CollectionItem()
                item.address = owner
                item.name = collection.collection.contractName
                item.count = collection.count
                item.collection = collection.collection
                
                item.loadFromCache()
                
                items.append(item)
            }
            
            self.items = items
        }
    }
    
    var selectedCollectionItem: CollectionItem? {
        if selectedIndex >= items.count {
            return nil
        }
        
        return items[selectedIndex]
    }
    
    func refreshCollectionAction() async throws {
        if isRequesting {
            return
        }
        
        isRequesting = true
        
        var collecitons = try await requestCollections()
        
        removeAllCache()
        
        collecitons.sort {
            if $0.count == $1.count {
                return $0.collection.contractName < $1.collection.contractName
            }
            
            return $0.count > $1.count
        }
        
        NFTUIKitCache.cache.saveCollectionToCache(collecitons)
        
        var items = [CollectionItem]()
        for collection in collecitons {
            let item = CollectionItem()
            item.address = owner
            item.name = collection.collection.contractName
            item.count = collection.count
            item.collection = collection.collection
            
            items.append(item)
        }
        
        DispatchQueue.syncOnMain {
            self.items = items
            self.isRequesting = false
        }
    }
    
    private func requestCollections() async throws -> [NFTCollection] {
        let response: Network.Response<[NFTCollection]> = try await Network.requestWithRawModel(LilicoAPI.NFT.collections(owner))
        if let list = response.data {
            return list
        } else {
            return []
        }
    }
    
    private func removeAllCache() {
        NFTUIKitCache.cache.removeCollectionCache()
        NFTUIKitCache.cache.removeAllNFTs()
    }
}
