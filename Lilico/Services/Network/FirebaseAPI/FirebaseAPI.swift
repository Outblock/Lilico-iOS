//
//  FirebaseAPI.swift
//  Lilico
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation
import Moya
import Flow
import BigInt

enum FirebaseAPI {
    case signAsPayer(SignPayerRequest)
    case moonPay(MoonPayRequest)
}

extension FirebaseAPI: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
#if LILICOPROD
        .init(string: "https://us-central1-lilico-334404.cloudfunctions.net")!
#else
        .init(string: "https://us-central1-lilico-dev.cloudfunctions.net")!
#endif
    }

    var path: String {
        switch self {
        case .signAsPayer:
            return "/signAsPayer"
        case .moonPay:
            return "/moonPaySignature"
        }
    }

    var method: Moya.Method {
        switch self {
        case .moonPay, .signAsPayer:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .moonPay(request):
            return .requestJSONEncodable(request)
        case let .signAsPayer(request):
            return .requestJSONEncodable(request)
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
