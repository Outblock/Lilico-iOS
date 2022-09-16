//
//  LilicoAPI+Flowns.swift
//  Lilico
//
//  Created by Selina on 16/9/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Flowns {
        case domainPrepare
        case domainSignature(SignPayerRequest)
    }
}

extension LilicoAPI.Flowns: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
#if LILICOPROD
        .init(string: "https://api.lilico.app")!
#else
        .init(string: "https://dev.lilico.app")!
#endif
    }
    
    var path: String {
        switch self {
        case .domainPrepare:
            return "/v1/flowns/prepare"
        case .domainSignature:
            return "/v1/flowns/signature"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .domainPrepare:
            return .get
        case .domainSignature:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .domainPrepare:
            return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
        case .domainSignature(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String : String]? {
        return LilicoAPI.commonHeaders
    }
}
