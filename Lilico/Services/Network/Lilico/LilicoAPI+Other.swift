//
//  LilicoAPI+Other.swift
//  Lilico
//
//  Created by Selina on 26/9/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Other {
        case swapEstimate(SwapEstimateRequest)
    }
}

extension LilicoAPI.Other: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        switch self {
        case .swapEstimate:
            return .init(string: "https://lilico.app")!
        default:
#if LILICOPROD
        return .init(string: "https://api.lilico.app")!
#else
        return .init(string: "https://dev.lilico.app")!
#endif
        }
    }
    
    var path: String {
        switch self {
        case .swapEstimate:
            return "/api/swap/v1/\(LocalUserDefaults.shared.flowNetwork == .testnet ? "testnet" : "mainnet")/estimate"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .swapEstimate:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .swapEstimate(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return LilicoAPI.commonHeaders
    }
}
