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
    let contractName: String
    let address: ContractAddress
    var banner: URL? = nil
    var officialWebsite: String?
    var marketplace: URL?
    var description: String?
    var path: ContractPath
    
    func address(mainnet: Bool = false) -> String {
        if(mainnet) {
            return address.mainnet
        }
        if(LocalUserDefaults.shared.flowNetwork == .testnet && (address.testnet != nil)) {
            return address.testnet!
        }
        return address.mainnet
    }
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
        return (response.contract.name ?? "") + " #" + response.id.tokenID
    }
    let image: URL
    var video: URL?
    let title: String
    let subtitle: String

    let response: NFTResponse
    let collection: NFTCollection?
    
    
    init(_ response: NFTResponse, in collection: NFTCollection?) {
        
        
        if let imgUrl = response.postMedia.image, let url = URL(string: imgUrl) {
            image = url
        }else {
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
        return collection?.logo ?? URL(string: placeholder)!
    }
    
    var tags: [NFTMetadatum] {
        return response.metadata.metadata.filter{ meta in
            !filterMetadata.contains(meta.name.lowercased()) && !meta.value.isEmpty && !meta.value.hasPrefix("https://")
        }
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
        return collection?.logo ?? URL(string: placeholder)!
    }
    
}
