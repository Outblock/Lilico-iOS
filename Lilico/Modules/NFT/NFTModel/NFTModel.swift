//
//  NFTModel.swift
//  Lilico
//
//  Created by cat on 2022/5/18.
//

import Foundation
import SwiftUI

let placeholder: String = "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png"
//TODO: which filter?
let filterMetadata = ["uri", "img", "description"]

struct NFTCollection: Codable, Hashable {
    let logo: URL?
    let name: String
    let address: ContractAddress
    var banner: URL? = nil
    var officialWebsite: String?
    var marketplace: URL?
    var description: String?
    var path: ContractPath
}

struct ContractAddress: Codable, Hashable {
    let mainnet: String
    let testnet: String?
}

struct ContractPath: Codable, Hashable {
    let storagePath: String
    let publicPath: String
    let publicCollectionName: String
}


struct NFTModel: Codable, Hashable, Identifiable {
    
    
    var id: String {
        return collections
    }
    let image: URL
    var video: URL?
    let name: String
    let collections: String

    let response: NFTResponse?
    let collection: NFTCollection?
    
    
    init(_ response: NFTResponse, in collection: NFTCollection?) {
        var url = response.imageUrl()
        if url == nil , let data = response.metadata.metadata.first(where: { $0.name.contains("image")}) {
            url = data.value
        }
        
        if url != nil  {
            url = url!.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
        }
        if url == nil || url!.isEmpty {
            url = placeholder
        }
        print("image-url: \(url!)")
        image = URL(string: url!)!
        if let videoUrl = response.videoUrl() {
            video = URL(string: videoUrl)
        }
        
        
        collections = (response.contract.name ?? "") + " #" + response.id.tokenID
        name = response.contract.name ?? ""
        self.collection = collection
        self.response = response
    }
    
    var declare: String {
        print("NFT Des: \(response?.description)")
        if let dec = response?.description {
            return dec
        }
        return ""
    }
    
    var logoUrl: URL {
        return collection?.logo ?? URL(string: placeholder)!
    }
    
    var tags:[NFTMetadatum] {
        return response?.metadata.metadata.filter{ meta in
            !filterMetadata.contains(meta.name.lowercased()) && !meta.value.isEmpty && !meta.value.hasPrefix("https://")
        } ?? []
    }
}

struct CollectionItem: Hashable, Identifiable {
    
    var id = UUID()
    var name: String
    var count: Int
    var collection: NFTCollection?
    var nfts: [NFTModel] = []
    
    var showName: String {
        return collection?.name ?? ""
    }
    
    var iconURL: URL {
        //TODO: logo placeholder
        return collection?.logo ?? URL(string: placeholder)!
    }
    
}
