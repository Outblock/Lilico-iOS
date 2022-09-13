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

// MARK: - 

extension FlowScanAccountTransferResponse {
    struct Data: Codable {
        let account: FlowScanAccountTransferResponse.Account?
    }
    
    struct Transactions: Codable {
        let edges: [Edge?]?
    }
    
    struct Edge: Codable {
        let node: FlowScanTransaction?
    }
    
    struct Account: Codable {
        let transactionCount: Int?
        let transactions: FlowScanAccountTransferResponse.Transactions?
    }
}

struct FlowScanAccountTransferResponse: Codable {
    let data: FlowScanAccountTransferResponse.Data?
}
