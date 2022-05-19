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
        case register(RegisterReuqest)
        case checkUsername(String)
        case userAddress
        case userInfo
        case userWallet
    }
}

extension LilicoAPI.User: TargetType, AccessTokenAuthorizable {
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        }
    }

    var headers: [String: String]? {
        nil
    }
}
