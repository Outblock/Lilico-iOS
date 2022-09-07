//
//  DAppModel.swift
//  Lilico
//
//  Created by Hao Fu on 29/8/2022.
//

import Foundation

struct DAppModel: Codable, Identifiable {
    let name: String
    let url: URL
    let testnetURL: URL?
    let description: String
    let logo: URL
    let category: String
    var id: URL {
        url
    }

    enum CodingKeys: String, CodingKey {
        case name, url
        case testnetURL = "testnet_url"
        case description
        case logo, category
    }
}
