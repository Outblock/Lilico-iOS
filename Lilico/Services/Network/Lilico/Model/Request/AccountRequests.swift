//
//  AccountRequests.swift
//  Lilico
//
//  Created by Selina on 14/9/2022.
//

import Foundation

struct TransfersRequest: Codable {
    let address: String
    let limit: Int
    let after: String
}
