//
//  LilicoAPI+Account.swift
//  Lilico
//
//  Created by Hao Fu on 19/5/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum User {
        case login(LoginRequest)
        case register(RegisterRequest)
        case checkUsername(String)
        case userAddress
        case userInfo
        case userWallet
    }
}

extension LilicoAPI.User: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app")!
    }

    var path: String {
        switch self {
        case .login:
            return "/v2/login"
        case .checkUsername:
            return "/v1/user/check"
        case .register:
            return "/v1/register"
        case .userAddress:
            return "/v1/user/address"
        case .userInfo:
            return "/v1/user/info"
        case .userWallet:
            return "/v1/user/wallet"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkUsername, .userInfo, .userWallet:
            return .get
        case .login, .register, .userAddress:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .userAddress, .userInfo, .userWallet:
            return .requestPlain
        case let .checkUsername(username):
            return .requestParameters(parameters: ["username": username], encoding: URLEncoding.queryString)
        case let .register(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        case let .login(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
