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

enum LilicoEndpoint {
    case register(RegisterReuqest)
    case checkUsername(String)
    case userAddress
    case userInfo
    case userWallet

    static var jsonEncoder: JSONEncoder {
        switch self {
        default:
            let coder = JSONEncoder()
            coder.keyEncodingStrategy = .convertToSnakeCase
            return coder
        }
    }
}

extension LilicoEndpoint: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app/v1")!
    }

    var path: String {
        switch self {
        case .checkUsername:
            return "/user/check"
        case .register:
            return "/register"
        case .userAddress:
            return "/user/address"
        case .userInfo:
            return "/user/info"
        case .userWallet:
            return "/user/wallet"
        }
    }

    var method: Moya.Method {
        switch self {
        case .checkUsername, .userInfo, .userWallet:
            return .get
        case .register, .userAddress:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .userAddress, .userInfo, .userWallet:
            return .requestPlain
        case .checkUsername(let username):
            return .requestParameters(parameters: ["username": username], encoding: URLEncoding.queryString)
        case let .register(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoEndpoint.jsonEncoder)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
