//
//  NFTListResponse.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation


struct NFTListResponse: Codable {
    let ownerAddress: String
    let nfts: [NFTResponse]
    let nftcount: Int
    let chain: String
    let network: String
    let offset: Int
}


struct NFTResponse: Codable {
    let id:String
    let contract:
    let title: String
    let description: String
    let media: URL
    let metadata: [NFTMetadataResponse]
}

struct NFTContract: Codable {
    let name: String
    let address: String
    let externalDomain: String
}

struct NFTMetadataResponse: Codable {
    let name: String
    let value: String
}

//// MARK: - NFTListResponse
//struct NFTListResponse: Codable {
//    let ownerAddress: String
//    let nfts: [Nft]
//    let chain, network: String
//    let nftCount, offset: Int
//}
//
//// MARK: - Nft
//struct Nft: Codable {
//    let contract: Contract
//    let id: ID
//    let media: Media
//    let metadata: Metadata
//}
//
//// MARK: - Contract
//struct Contract: Codable {
//    let name, address, externalDomain: String
//    let contractMetadata: ContractMetadata
//}
//
//// MARK: - ContractMetadata
//struct ContractMetadata: Codable {
//    let storagePath, publicPath, publicCollectionName: String
//}
//
//// MARK: - ID
//struct ID: Codable {
//    let tokenID: String
//    let tokenMetadata: TokenMetadata
//
//    enum CodingKeys: String, CodingKey {
//        case tokenID = "tokenId"
//        case tokenMetadata
//    }
//}
//
//// MARK: - TokenMetadata
//struct TokenMetadata: Codable {
//    let uuid: String
//}
//
//// MARK: - Media
//struct Media: Codable {
//    let uri, mimeType: String
//}
//
//// MARK: - Metadata
//struct Metadata: Codable {
//    let metadata: [Metadatum]
//}
//
//// MARK: - Metadatum
//struct Metadatum: Codable {
//    let name, value: String
//}
