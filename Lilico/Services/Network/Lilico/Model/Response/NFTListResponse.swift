//
//  NFTListResponse.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

// MARK: - NFTListResponse
struct NFTListResponse: Codable {
    let nfts: [NFTResponse]?
    let nftCount: Int
}

// MARK: - NFTFavListResponse
struct NFTFavListResponse: Codable {
    let nfts: [NFTResponse]?
    let chain, network: String
    let nftcount: Int
}

// MARK: - Nft

struct NFTResponse: Codable, Hashable {
    let id: String
    let name: String?
    let description: String?
    let thumbnail: String?
    let externalURL: String?
    let contractAddress: String?
    
    let collectionID: String?
    let collectionName: String?
    let collectionDescription: String?
    let collectionSquareImage: String?
    let collectionExternalURL: String?
    let collectionContractName: String?
    let collectionBannerImage: String?
    
    let traits: [NFTTrait]?
    var postMedia: NFTPostMedia
    
    var uniqueId: String {
        return (contractAddress ?? "") + "." + (collectionName ?? "") + "-" + "\(id)"
    }

    func cover() -> String? {
        return postMedia.image ?? postMedia.video
    }

    func video() -> String? {
        return postMedia.video
    }
}

struct NFTRoyalty: Codable, Hashable {
    let cut: Double?
    let description: String?
}

struct NFTRoyaltyReceiver: Codable, Hashable {
    let address: String?
}

struct NFTRoyaltyReceiverPath: Codable, Hashable {
    let type: String?
    let value: NFTRoyaltyReceiverPathValue?
}

struct NFTRoyaltyReceiverPathValue: Codable, Hashable {
    let identifier: String?
    let domain: String?
}

struct NFTRoyaltyBorrowType: Codable, Hashable {
    let kind: String?
    let authorized: Bool?
    let type: NFTRoyaltyBorrowTypeType?
}

struct NFTRoyaltyBorrowTypeType: Codable, Hashable {
    let typeID: String?
    let kind: String?
    let type: NFTRoyaltyBorrowTypeTypeType?
    let restrictions: [NFTRoyaltyBorrowTypeTypeType]?
}

struct NFTRoyaltyBorrowTypeTypeType: Codable, Hashable {
    let typeID: String?
    let fields: [NFTRoyaltyBorrowTypeTypeTypeField]?
    let kind: String?
//    let type:
//    let initializers: []
}

struct NFTRoyaltyBorrowTypeTypeTypeField: Codable, Hashable {
    let id: String?
    let type: NFTRoyaltyBorrowTypeTypeTypeFieldType?
}

struct NFTRoyaltyBorrowTypeTypeTypeFieldType: Codable, Hashable {
    let kind: String?
}

struct NFTPostMedia: Codable, Hashable {
    let title: String?
    var image: String?
    let description: String?
    let video: String?
    let isSvg: String?
}

// MARK: - TokenMetadata

struct NFTTokenMetadata: Codable, Hashable {
    let uuid: String
}

// MARK: - Metadata

struct NFTTrait: Codable, Hashable {
    let name: String?
    let value: String?
    let displayType: String?
//    let rarity:
}
