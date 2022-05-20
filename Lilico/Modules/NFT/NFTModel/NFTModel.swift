//
//  NFTModel.swift
//  Lilico
//
//  Created by cat on 2022/5/18.
//

import Foundation

let placeholder: String = "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png"

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
    var id = UUID()
    let image: URL
    let name: String
    let collections: String

    let response: NFTResponse?
    let collection: NFTCollection?
    
    init(_ response: NFTResponse, in collection: NFTCollection?) {
        var url = response.media?.first?.uri
        if url == nil , let data = response.metadata.metadata.first(where: { $0.name.contains("image")}) {
            url = data.value
        }
        
        if url != nil  {
            url = url!.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
        }
        if url == nil || url!.isEmpty {
            url = placeholder
        }
        
        image = URL(string: url!)!
        collections = (response.contract.name ?? "") + " #" + response.id.tokenID
        name = response.contract.name ?? ""
        self.collection = collection
        self.response = response
    }
    
    var declare: String {
        if let dec = response?.description {
            return dec
        }
        return ""
    }
    
    var logoUrl: URL {
        return collection?.logo ?? URL(string: placeholder)!
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
