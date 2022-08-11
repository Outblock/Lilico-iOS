//
//  NFTRequests.swift
//  Lilico
//
//  Created by Selina on 9/8/2022.
//

import Foundation

struct NFTGridDetailListRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var offset: Int = 0
    var limit: Int = 25
}

struct NFTCollectionDetailListRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var contractName: String
    var offset: Int = 0
    var limit: Int = 25
}
