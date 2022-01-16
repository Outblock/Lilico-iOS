//
//  AlchemyEndpoint.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Moya

struct NFTListRequest: Codable {
    var owner: String = "0x2b06c41f44a05656"
    var offset: Int = 0
    var limit: Int = 100
}

enum AlchemyEndpoint {
    case nftList(NFTListRequest)
}

extension AlchemyEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://flow-mainnet.g.alchemy.com/demo/v1/")!
    }
    
    var path: String {
        switch self {
        case .nftList:
            return "getNFTs"
        }
    }
    
    var method: Moya.Method {
        .get
    }
    
    var task: Task {
        switch self {
        case .nftList(let nftListRequest):
            return .requestParameters(parameters: nftListRequest.dictionary ?? [:], encoding: URLEncoding())
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}
