//
//  NFTListResponse.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation


//// MARK: - NFTListResponse
struct NFTListResponse: Codable {
    let ownerAddress: String
    let nfts: [NFTResponse]
    let chain, network: String
    let nftCount, offset: Int
}

// MARK: - Nft
struct NFTResponse: Codable, Hashable {
    let contract: NFTContract
    let id: NFTID
    let title: String?
    let description: String?
    let media: [NFTMedia]?
    let metadata: NFTMetadata
}

// MARK: - Contract
struct NFTContract: Codable, Hashable {
    let name: String?
    let address, externalDomain: String
    let contractMetadata: NFTContractMetadata
}

// MARK: - ContractMetadata
struct NFTContractMetadata: Codable, Hashable {
    let storagePath, publicPath, publicCollectionName: String
}

// MARK: - ID
struct NFTID: Codable, Hashable {
    let tokenID: String
    let tokenMetadata: NFTTokenMetadata

    enum CodingKeys: String, CodingKey {
        case tokenID = "tokenId"
        case tokenMetadata
    }
}

// MARK: - TokenMetadata
struct NFTTokenMetadata: Codable, Hashable {
    let uuid: String
}

// MARK: - Media
struct NFTMedia: Codable, Hashable {
    let uri, mimeType: String
}

// MARK: - Metadata
struct NFTMetadata: Codable , Hashable{
    let metadata: [NFTMetadatum]
}

// MARK: - Metadatum
struct NFTMetadatum: Codable, Hashable {
    let name: String
    let value: String
}
