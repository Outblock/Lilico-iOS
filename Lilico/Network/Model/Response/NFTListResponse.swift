//
//  NFTListResponse.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation


//struct NFTListResponse: Codable {
//    let ownerAddress: String
//    let nfts: [NFTResponse]
//    let nftcount: Int
//    let chain: String
//    let network: String
//    let offset: Int
//}
//
//
//struct NFTResponse: Codable {
//    let id: String
//    let contract:
//    let title: String
//    let description: String
//    let media: URL
//    let metadata: [NFTMetadataResponse]
//}
//
//struct NFTContract: Codable {
//    let name: String
//    let address: String
//    let externalDomain: String
//}
//
//struct NFTMetadataResponse: Codable {
//    let name: String
//    let value: String
//}

//// MARK: - NFTListResponse
struct NFTListResponse: Codable {
    let ownerAddress: String
    let nfts: [NFTResponse]
    let chain, network: String
    let nftCount, offset: Int
}

// MARK: - Nft
struct NFTResponse: Codable {
    let contract: NFTContract
    let id: NFTID
    let media: NFTMedia?
    let metadata: NFTMetadata
}

// MARK: - Contract
struct NFTContract: Codable, Hashable {
    let name, address, externalDomain: String
    let contractMetadata: NFTContractMetadata
}

// MARK: - ContractMetadata
struct NFTContractMetadata: Codable, Hashable {
    let storagePath, publicPath, publicCollectionName: String
}

// MARK: - ID
struct NFTID: Codable {
    let tokenID: String
    let tokenMetadata: NFTTokenMetadata

    enum CodingKeys: String, CodingKey {
        case tokenID = "tokenId"
        case tokenMetadata
    }
}

// MARK: - TokenMetadata
struct NFTTokenMetadata: Codable {
    let uuid: String
}

// MARK: - Media
struct NFTMedia: Codable {
    let uri, mimeType: String
}

// MARK: - Metadata
struct NFTMetadata: Codable {
    let metadata: [NFTMetadatum]
}

// MARK: - Metadatum
struct NFTMetadatum: Codable {
    let name, value: String
}
