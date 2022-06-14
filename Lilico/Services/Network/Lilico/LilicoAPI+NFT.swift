//
//  LilicoAPI+NFT.swift
//  Lilico
//
//  Created by cat on 2022/6/14.
//

import Foundation

import Foundation
import Moya

struct NFTRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var offset: Int = 0
    var limit: Int = 25
}

extension LilicoAPI {
    enum NFT {
        case list(NFTRequest)
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
        case .list(_):
            return "v2/nft/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .list(_):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .list(let nftListRequest):
            return .requestParameters(parameters: nftListRequest.dictionary ?? [:], encoding: URLEncoding())
        }
    }
    
    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
