//
//  LilicoAPI+Crypto.swift
//  Lilico
//
//  Created by Selina on 23/6/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Crypto {
        case summary(CryptoSummaryRequest)
        case history(CryptoHistoryRequest)
    }
}

extension LilicoAPI.Crypto: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app/v1")!
    }

    var path: String {
        switch self {
        case .summary:
            return "/crypto/summary"
        case .history:
            return "/crypto/history"
        }
    }

    var method: Moya.Method {
        switch self {
        case .summary, .history:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .summary(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case let .history(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
