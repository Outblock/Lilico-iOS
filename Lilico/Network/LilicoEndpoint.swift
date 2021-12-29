//
//  LilicoEndpoint.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation
import Moya

let lilicoProvider = MoyaProvider<LilicoEndpoint>()

enum LilicoEndpoint {
    case checkUsername(String)
}

extension LilicoEndpoint: TargetType {
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
    
    var headers: [String : String]? {
        nil
    }
    
    
}
