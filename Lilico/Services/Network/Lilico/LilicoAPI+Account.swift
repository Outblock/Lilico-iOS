//
//  LilicoAPI+Account.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum Account {
        case flowScanQuery(String)
    }
}

extension LilicoAPI.Account: TargetType, AccessTokenAuthorizable {
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
        case .flowScanQuery:
            return "/v1/account/query"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .flowScanQuery:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .flowScanQuery(let query):
            return .requestJSONEncodable(["query": query])
        }
    }
    
    var headers: [String : String]? {
        return LilicoAPI.commonHeaders
    }
}

extension LilicoAPI.Account {
    static func fetchAccountTransferCount() async throws -> Int {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return 0
        }
        
        let script = """
            query TransfersNumber {
                account(id: "\(address)") {
                    transactionCount
                }
            }
        """
        
        let response: FlowScanAccountTransferCountResponse = try await Network.request(LilicoAPI.Account.flowScanQuery(script))
        return response.data?.account?.transactionCount ?? 0
    }
}
