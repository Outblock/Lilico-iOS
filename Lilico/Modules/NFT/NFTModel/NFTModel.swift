//
//  NFTModel.swift
//  Lilico
//
//  Created by cat on 2022/5/18.
//

import Foundation

let placeholder: String = "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png"

struct NFTCollection: Decodable, Hashable {
    let logo: URL?
    let name: String
    let address: ContractAddress
    var banner: URL? = nil
    var officialWebsite: String?
    var marketplace: URL?
    var description: String?
    var path: ContractPath
}

struct ContractAddress: Decodable, Hashable {
    let mainnet: String
    let testnet: String?
}

struct ContractPath: Decodable, Hashable {
    let storagePath: String
    let publicPath: String
    let publicCollectionName: String
}


struct NFTModel: Codable, Hashable, Identifiable {
    var id = UUID()
    let image: URL
    let name: String
    let collections: String
    let nft: NFTResponse?
    
    init(nft: NFTResponse) {
        var url = nft.media?.first?.uri
        if url == nil , let data = nft.metadata.metadata.first(where: { $0.name.contains("image")}) {
            url = data.value
        }
        
        if url != nil  {
            url = url!.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
        }
        if url == nil || url!.isEmpty {
            url = placeholder
        }
        
        image = URL(string: url!)!
        name = nft.contract.name ?? "" + " #" + nft.id.tokenID
        collections = nft.contract.name ?? ""
        self.nft = nft
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
