//
//  NFTCatalogCache.swift
//  FlowCore
//
//  Created by cat on 2023/9/11.
//

import Foundation

class NFTCatalogCache {
    
    var isLoading: Bool = true
    
    static let cache = NFTCatalogCache()
    
    private var collectionList: [NFTCollectionItem] = []
    
    private lazy var rootFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("nft_catalog")
    private lazy var file = rootFolder.appendingPathComponent("list")

    
    private init() {
        createFolderIfNeed()
        load()
    }
    
    func fetchIfNeed() {
        
        let cur = Int(CFAbsoluteTime())
        let pre = UserDefaults.standard.integer(forKey: "nft_catalog_pre_time")
        if pre == 0 || (cur - pre) > 24 * 60 * 60 {
            debugPrint("[NFT] catalog fetch because timeout")
            Task {
                await fetch()
            }
        }
    }
    
    private  func fetch() async {
        
        self.isLoading = true
        
        await NFTCollectionConfig.share.reload()
        await NFTCollectionStateManager.share.fetch()
        collectionList.removeAll { _ in true }
        collectionList = NFTCollectionConfig.share.config.filter({ col in
            !col.address.isEmpty
        })
        .map({ it in
            var status = NFTCollectionItem.ItemStatus.idle
            if(NFTCollectionStateManager.share.isTokenAdded(it.address)) {
                status = .own
            }
            return NFTCollectionItem(collection: it, status: status)
        })
        self.isLoading = false
        self.save()
        
    }
    
    private  func load()  {
        if !FileManager.default.fileExists(atPath: file.relativePath) {
            Task {
                await fetch()
            }
            return
        }
        
        do {
            let data = try Data(contentsOf: file)
            let nfts = try JSONDecoder().decode([NFTCollectionItem].self, from: data)
            collectionList = nfts
        } catch {
            debugPrint("NFTCatalogCache -> load error: \(error)")
        }
    }
    
    private  func save() {
        do {
            let data = try JSONEncoder().encode(collectionList)
            try data.write(to: file)
        } catch {
            debugPrint("NFTUIKitCache -> saveCurrentFavToCache error: \(error)")
        }
    }
    
    func find(by storagePath: String ) -> NFTCollectionItem? {
        let result = collectionList.filter { item in
            item.collection.path.storagePath == storagePath
        }.first
        return result
    }
    
}

extension NFTCatalogCache {
    
    private func createFolderIfNeed() {
        do {
            if !FileManager.default.fileExists(atPath: rootFolder.relativePath) {
                try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true)
            }
        }
        catch {
            debugPrint("NFTCatalog -> createFolderIfNeeded error: \(error)")
        }
    }
}
