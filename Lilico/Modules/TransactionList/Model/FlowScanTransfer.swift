//
//  FlowScanTransfer.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import SwiftUI

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
    
    var statusColor: UIColor {
        if status != "Sealed" {
            return UIColor.LL.Neutrals.text3
        }
        
        if let error = error, error == true {
            return UIColor.LL.Warning.warning2
        } else {
            return UIColor.LL.Success.success3
        }
    }
    
    var statusText: String {
        if status != "Sealed" {
            return "transaction_pending".localized
        }
        
        if let error = error, error == true {
            return "transaction_error".localized
        } else {
            return status ?? "transaction_pending".localized
        }
    }
    
    var transferDesc: String {
        var dateString = ""
        if let time = time, let df = ISO8601Formatter.date(from: time) {
            dateString = df.mmmddString
        }
        
        var targetStr = ""
        if self.transfer_type == .send {
            targetStr = "transfer_to_x".localized(self.receiver ?? "")
        } else if self.sender != nil {
            targetStr = "transfer_from_x".localized(self.sender ?? "")
        }
        
        return "\(dateString) \(targetStr)"
    }
}
