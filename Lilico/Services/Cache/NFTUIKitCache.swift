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
    
    init() {
        createFolderIfNeeded()
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

