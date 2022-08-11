//
//  LilicoAPI+NFT.swift
//  Lilico
//
//  Created by cat on 2022/6/14.
//

import Foundation
import Moya

extension LilicoAPI {
    enum NFT {
        case collections(String)
        case collectionDetailList(NFTCollectionDetailListRequest)
        case gridDetailList(NFTGridDetailListRequest)
    }
}

extension LilicoAPI.NFT: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app")!
    }

    var path: String {
        switch self {
        case .gridDetailList:
            return "v2/nft/detail/list"
        case .collections:
            return "v2/nft/collections"
        case .collectionDetailList:
            return "v2/nft/single"
        }
    }

    var method: Moya.Method {
        switch self {
        case .collections, .collectionDetailList, .gridDetailList:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .gridDetailList(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case let .collectionDetailList(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case let .collections(address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding())
        }
    }

    var headers: [String: String]? {
        var headers = LilicoAPI.commonHeaders

        #if DEBUG
            // TODO: current nft is error on testnet, remove this code if testnet nft is working someday.
            headers["Network"] = LocalUserDefaults.FlowNetworkType.mainnet.rawValue
        #endif
        return headers
    }
}
