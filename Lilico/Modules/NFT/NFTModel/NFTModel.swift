//
//  NFTModel.swift
//  Lilico
//
//  Created by cat on 2022/5/18.
//

import Foundation
import SwiftUI
import Flow

let placeholder: String = "https://lilico.app/placeholder.png"
// TODO: which filter?
let filterMetadata = ["uri", "img", "description"]

struct NFTCollection: Codable {
    let collection: NFTCollectionInfo
    let count: Int
    let ids: [Int]?
}

struct NFTCollectionInfo: Codable, Hashable {
    let logo: String?
    let name: String
    let contractName: String
    let address: ContractAddress
    let secureCadenceCompatible: SecureCadenceCompatible
    var banner: String?
    var officialWebsite: String?
    var marketplace: String?
    var description: String?
    var path: ContractPath
    
    func currentAddress(forceMainnet: Bool = false) -> String {
        if(forceMainnet) {
            return address.mainnet
        }else {
            if LocalUserDefaults.shared.flowNetwork == .testnet &&  address.testnet != nil && !address.testnet!.isEmpty {
                return address.testnet!
            }
        }
        return address.mainnet
    }
    
    var logoURL: URL {
        if let logoString = logo {
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }
}

struct ContractAddress: Codable, Hashable {
    let mainnet: String
    let testnet: String?
    
    func chooseBy(network: Flow.ChainID = LocalUserDefaults.shared.flowNetwork.toFlowType()) -> String? {
        switch network {
        case .mainnet:
            return mainnet
        case .testnet:
            return testnet
        default:
            return mainnet
        }
    }
}

struct SecureCadenceCompatible: Codable, Hashable {
    let mainnet: Bool
    let testnet: Bool
}

struct ContractPath: Codable, Hashable {
    let storagePath: String
    let publicPath: String
    let publicCollectionName: String
}

struct NFTModel: Codable, Hashable, Identifiable {
    var id: String {
        return response.contract.address + "." + (response.contract.name ?? "") + "-" + response.id.tokenID
    }

    let image: URL
    var video: URL?
    let title: String
    let subtitle: String
    var isSVG: Bool = false
    let response: NFTResponse
    let collection: NFTCollectionInfo?

    init(_ response: NFTResponse, in collection: NFTCollectionInfo?) {
        if let imgUrl = response.postMedia.image, let url = URL(string: imgUrl) {
            image = url
            isSVG = response.postMedia.isSVG ?? false
        } else {
            image = URL(string: placeholder)!
        }

        if let videoUrl = response.postMedia.video {
            video = URL(string: videoUrl)
        }

        subtitle = response.postMedia.description ?? ""
        title = response.postMedia.title ?? response.contract.name ?? ""
        self.collection = collection
        self.response = response
    }

    var declare: String {
        if let dec = response.postMedia.description {
            return dec
        }
        return response.description ?? ""
    }

    var logoUrl: URL {
        if let logoString = collection?.logo {
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }

    var tags: [NFTMetadatum] {
        guard let metadata = response.metadata?.metadata else {
            return []
        }
        
        return metadata.filter { meta in
            !filterMetadata.contains(meta.name.lowercased()) && !meta.value.isEmpty && !meta.value.hasPrefix("https://")
        }
    }
}

class CollectionItem: Identifiable {
    var address: String = ""
    var id = UUID()
    var name: String = ""
    var count: Int = 0
    var collection: NFTCollectionInfo?
    var nfts: [NFTModel] = []
    var loadCallback: ((Bool) -> ())? = nil
    
    var isEnd: Bool = false
    var isRequesting: Bool = false

    var showName: String {
        return collection?.name ?? ""
    }

    var iconURL: URL {
        if let logoString = collection?.logo {
            return URL(string: logoString) ?? URL(string: placeholder)!
        }
        
        return URL(string: placeholder)!
    }
    
    func loadFromCache() {
        if let cachedNFTs = NFTUIKitCache.cache.getNFTs(contractName: name) {
            let models = cachedNFTs.map { NFTModel($0, in: self.collection) }
            self.nfts = models
        }
    }
    
    func load() {
        if isRequesting || isEnd {
            return
        }
        
        isRequesting = true
        
        let limit = 24
        Task {
            do {
                let response = try await requestCollectionListDetail(offset: nfts.count, limit: limit)
                DispatchQueue.main.async {
                    self.isRequesting = false
                    
                    guard let list = response.nfts, !list.isEmpty else {
                        self.isEnd = true
                        return
                    }
                    
                    let nftModels = list.map { NFTModel($0, in: self.collection) }
                    self.appendNFTsNoDuplicated(nftModels)
                    
                    if list.count != limit {
                        self.isEnd = true
                    }
                    
                    self.saveNFTsToCache()
                    
                    self.loadCallback?(true)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.loadCallback?(false)
                }
            }
        }
    }
    
    private func appendNFTsNoDuplicated(_ newNFTs: [NFTModel]) {
        for nft in newNFTs {
            let exist = nfts.first { $0.id == nft.id }
            
            if exist == nil {
                nfts.append(nft)
            }
        }
    }
    
    private func requestCollectionListDetail(offset: Int, limit: Int = 24) async throws -> NFTListResponse {
        let request = NFTCollectionDetailListRequest(address: address, contractName: name, offset: offset, limit: limit)
        let response: NFTListResponse = try await Network.request(LilicoAPI.NFT.collectionDetailList(request))
        return response
    }
    
    private func saveNFTsToCache() {
        let models = nfts.map { $0.response }
        NFTUIKitCache.cache.saveNFTsToCache(models, contractName: name)
    }
}
