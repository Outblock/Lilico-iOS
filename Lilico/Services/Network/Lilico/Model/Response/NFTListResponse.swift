//
//  NFTListResponse.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

// MARK: - NFTListResponse
struct NFTListResponse: Codable {
    let ownerAddress: String?
    let nfts: [NFTResponse]?
    let chain, network: String
    let nftCount: Int
    let offset: Int?
}

// MARK: - NFTFavListResponse
struct NFTFavListResponse: Codable {
    let nfts: [NFTResponse]?
    let chain, network: String
    let nftcount: Int
}

// MARK: - Nft

struct NFTResponse: Codable, Hashable {
    let contract: NFTContract
    let id: NFTID
    let title: String?
    let description: String?
    let media: [NFTMedia]?
    let metadata: NFTMetadata?
    var postMedia: NFTPostMedia
    
    var uniqueId: String {
        return contract.address + "." + (contract.name ?? "") + "-" + id.tokenID
    }

    func cover() -> String? {
        return postMedia.image ?? postMedia.video
    }

    func video() -> String? {
        return postMedia.video
    }

    func name() -> String? {
        if let title = title, !title.isEmpty {
            return title
        }

        guard let name = contract.name else {
            return nil
        }

        return "\(name) #\(id.tokenID)"
    }
}

// MARK: - Contract

struct NFTContract: Codable, Hashable {
    let name: String?
    let address, externalDomain: String
    let contractMetadata: NFTContractMetadata?
}

// MARK: - ContractMetadata

struct NFTContractMetadata: Codable, Hashable {
    let storagePath, publicPath, publicCollectionName: String
}

struct NFTPostMedia: Codable, Hashable {
    let title: String?
    var image: String?
    let description: String?
    let video: String?
    let isSVG: String?
}

// MARK: - ID

struct NFTID: Codable, Hashable {
    let tokenID: String
    let tokenMetadata: NFTTokenMetadata?

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
    let uri: String
    let mimeType: String?
}

// MARK: - Metadata

struct NFTMetadata: Codable, Hashable {
    let metadata: [NFTMetadatum]?
}

// MARK: - Metadatum

struct NFTMetadatum: Codable, Hashable {
    let name: String
    let value: String
}