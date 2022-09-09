//
//  AccountResponses.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import Foundation

extension FlowScanAccountTransferCountResponse {
    struct Data: Codable {
        let account: FlowScanAccountTransferCountResponse.Account?
    }
    
    struct Account: Codable {
        let transactionCount: Int?
    }
}

struct FlowScanAccountTransferCountResponse: Codable {
    let data: FlowScanAccountTransferCountResponse.Data?
}
