//
//  FlowScanTransfer.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import Foundation

extension FlowScanTransfer {
    enum TransferType: Int, Codable {
        case unknown
        case send
        case receive
    }
}

struct FlowScanTransfer: Codable {
    let additional_message: String?
    let amount: String?
    let error: Bool?
    let image: String?
    let receiver: String?
    let sender: String?
    let status: String?
    let time: String?
    let title: String?
    let token: String?
    let transfer_type: TransferType?
    let txid: String?
    let type: Int?
}
