//
//  NFTUIKitCache.swift
//  Lilico
//
//  Created by Selina on 16/8/2022.
//

import UIKit

class NFTUIKitCache {
    static let cache = NFTUIKitCache()
    
    private lazy var rootFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("nft_uikit_cache")
    
    private lazy var collectionFolder = rootFolder.appendingPathComponent("collection")
    private lazy var collectionCacheFile = collectionFolder.appendingPathComponent("collection_cache_file")
    
    private lazy var nftFolder = rootFolder.appendingPathComponent("nft")
    
    private lazy var gridFolder = rootFolder.appendingPathComponent("grid")
    private lazy var gridCacheFile = gridFolder.appendingPathComponent("grid_cache_file")
    
    private lazy var favFolder = rootFolder.appendingPathComponent("fav")
    private lazy var favCacheFile = gridFolder.appendingPathComponent("fav_cache_file")
    
    private(set) var favList: [NFTModel] = []
    private var favIsRequesting: Bool = false
    
    init() {
        createFolderIfNeeded()
        // TODO: Test
        removeFavCache()
        loadFavCache()
    }
    
    private func createFolderIfNeeded() {
        do {
            if !FileManager.default.fileExists(atPath: rootFolder.relativePath) {
                try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: collectionFolder.relativePath) {
                try FileManager.default.createDirectory(at: collectionFolder, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: nftFolder.relativePath) {
                try FileManager.default.createDirectory(at: nftFolder, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: gridFolder.relativePath) {
                try FileManager.default.createDirectory(at: gridFolder, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: favFolder.relativePath) {
                try FileManager.default.createDirectory(at: favFolder, withIntermediateDirectories: true)
            }
        } catch {
            debugPrint("NFTUIKitCache -> createFolderIfNeeded error: \(error)")
        }
    }
}

// MARK: - Grid

extension NFTUIKitCache {
    func saveGridToCache(_ nfts: [NFTResponse]) {
        if nfts.isEmpty {
            removeGridCache()
            return
        }
        
        do {
            let data = try JSONEncoder().encode(nfts)
            try data.write(to: gridCacheFile)
        } catch {
            debugPrint("NFTUIKitCache -> saveGridToCache: error: \(error)")
            removeGridCache()
        }
    }
    
    func removeGridCache() {
        if FileManager.default.fileExists(atPath: gridCacheFile.relativePath) {
            do {
                try FileManager.default.removeItem(at: gridCacheFile)
            } catch {
                debugPrint("NFTUIKitCache -> removeGridCache error: \(error)")
            }
        }
    }
    
    func getGridNFTs() -> [NFTResponse]? {
        if !FileManager.default.fileExists(atPath: gridCacheFile.relativePath) {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: gridCacheFile)
            let nfts = try JSONDecoder().decode([NFTResponse].self, from: data)
            return nfts
        } catch {
            debugPrint("NFTUIKitCache -> getGridNFTs error: \(error)")
            return nil
        }
    }
}

// MARK: - Collection

extension NFTUIKitCache {
    func saveCollectionToCache(_ collections: [NFTCollection]) {
        if collections.isEmpty {
            removeCollectionCache()
            return
        }
        
        do {
            let data = try JSONEncoder().encode(collections)
            try data.write(to: collectionCacheFile)
        } catch {
            debugPrint("NFTUIKitCache -> saveCollectionToCache: error: \(error)")
            removeCollectionCache()
        }
    }
    
    func removeCollectionCache() {
        if FileManager.default.fileExists(atPath: collectionCacheFile.relativePath) {
            do {
                try FileManager.default.removeItem(at: collectionCacheFile)
            } catch {
                debugPrint("NFTUIKitCache -> removeCollectionCache error: \(error)")
            }
        }
    }
    
    func getCollections() -> [NFTCollection]? {
        if !FileManager.default.fileExists(atPath: collectionCacheFile.relativePath) {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: collectionCacheFile)
            let collections = try JSONDecoder().decode([NFTCollection].self, from: data)
            return collections
        } catch {
            debugPrint("NFTUIKitCache -> getCollections error: \(error)")
            return nil
        }
    }
}

// MARK: - NFTs

extension NFTUIKitCache {
    func saveNFTsToCache(_ nfts: [NFTResponse], contractName: String) {
        if nfts.isEmpty {
            removeNFTs(contractName: contractName)
            return
        }
        
        let md5 = contractName.md5
        let fileURL = nftFolder.appendingPathComponent(md5)
        
        do {
            let data = try JSONEncoder().encode(nfts)
            try data.write(to: fileURL)
        } catch {
            debugPrint("NFTUIKitCache -> saveNFTsToCache: error: \(error)")
            removeNFTs(contractName: contractName)
        }
    }
    
    func removeNFTs(contractName: String) {
        let md5 = contractName.md5
        let fileURL = nftFolder.appendingPathComponent(md5)
        
        if FileManager.default.fileExists(atPath: fileURL.relativePath) {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                debugPrint("NFTUIKitCache -> removeNFTs: error: \(error)")
            }
        }
    }
    
    func removeAllNFTs() {
        if FileManager.default.fileExists(atPath: nftFolder.relativePath) {
            do {
                try FileManager.default.removeItem(at: nftFolder)
                try FileManager.default.createDirectory(at: nftFolder, withIntermediateDirectories: true)
            } catch {
                debugPrint("NFTUIKitCache -> removeAllNFTs error: \(error)")
            }
        }
    }
    
    func getNFTs(contractName: String) -> [NFTResponse]? {
        let md5 = contractName.md5
        let fileURL = nftFolder.appendingPathComponent(md5)
        
        if !FileManager.default.fileExists(atPath: fileURL.relativePath) {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let nfts = try JSONDecoder().decode([NFTResponse].self, from: data)
            return nfts
        } catch {
            debugPrint("NFTUIKitCache -> getNFTs: \(contractName) error: \(error)")
            return nil
        }
    }
}

// MARK: - Fav

extension NFTUIKitCache {
    private func loadFavCache() {
        if !FileManager.default.fileExists(atPath: favCacheFile.relativePath) {
            return
        }
        
        do {
            let data = try Data(contentsOf: favCacheFile)
            let nfts = try JSONDecoder().decode([NFTModel].self, from: data)
            favList = nfts
        } catch {
            debugPrint("NFTUIKitCache -> loadFavCache error: \(error)")
        }
    }
    
    private func saveCurrentFavToCache() {
        do {
            let data = try JSONEncoder().encode(favList)
            try data.write(to: favCacheFile)
        } catch {
            debugPrint("NFTUIKitCache -> saveCurrentFavToCache error: \(error)")
        }
    }
    
    func removeFavCache() {
        if !FileManager.default.fileExists(atPath: favCacheFile.relativePath) {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: favCacheFile)
        } catch {
            debugPrint("NFTUIKitCache -> removeFavCache error: \(error)")
        }
    }
    
    func isFav(id: String) -> Bool {
        for nft in favList {
            if nft.id == id {
                return true
            }
        }
        
        return false
    }
    
    func addFav(nft: NFTModel) {
        guard let contractName = nft.response.contract.name else {
            return
        }
        
        if let _ = favList.firstIndex(where: { $0.id == nft.id }) {
            return
        }
        
        favList.insert(nft, at: 0)
        saveCurrentFavToCache()
        
        let address = nft.response.contract.address
        let tokenId = nft.response.id.tokenID
        
        let request = NFTAddFavRequest(address: address, contract: contractName, ids: tokenId)
        Task {
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.NFT.addFav(request))
            } catch {
                debugPrint("NFTUIKitCache -> addFav error: \(error)")
            }
        }
        
    }
    
    func removeFav(id: String) {
        if let index = favList.firstIndex(where: { $0.id == id }) {
            favList.remove(at: index)
            saveCurrentFavToCache()
            
            let ids = generateFavUpdateStrings()
            Task {
                do {
                    let request = NFTUpdateFavRequest(ids: ids)
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.NFT.updateFav(request))
                } catch {
                    debugPrint("NFTUIKitCache -> removeFav error: \(error)")
                }
            }
        }
    }
    
    private func generateFavUpdateStrings() -> String {
        var array = [String]()
        for nft in favList {
            if let contractName = nft.response.contract.name {
                let tokenId = nft.response.id.tokenID
                array.append("\(contractName)-\(tokenId)")
            }
        }
        
        let str = array.joined(separator: ",")
        return str
    }
    
    func requestFav() {
        if favIsRequesting {
            return
        }
        
        guard var address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        favIsRequesting = true
        
        Task {
            do {
                let request: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.NFT.favList(address))
                if request.httpCode == 404 {
                    // empty
                    debugPrint("NFTUIKitCache -> requestFav is empty")
                    return
                }
            } catch {
                debugPrint("NFTUIKitCache -> requestFav error: \(error)")
            }
        }
    }
}
