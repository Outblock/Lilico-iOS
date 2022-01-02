//
//  LilicoEndpoint.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import FirebaseAuth
import Foundation
import Haneke
import Moya
import Resolver

let authPlugin = AccessTokenPlugin { _ in
    ""
}

let lilicoProvider = MoyaProvider<LilicoEndpoint>(plugins: [authPlugin, NetworkLoggerPlugin()])

enum LilicoEndpoint {
    case checkUsername(String)
}

extension LilicoEndpoint: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app")!
    }

    var path: String {
        switch self {
        case let .checkUsername(name):
            return "/user/check/\(name)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkUsername:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .checkUsername:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
