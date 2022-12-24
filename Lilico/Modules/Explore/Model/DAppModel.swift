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
    let sandboxnetURL: URL?
    let description: String
    let logo: URL
    let category: String
    var id: URL {
        url
    }
    
    var networkURL: URL? {
        switch currentNetwork {
        case .mainnet:
            return url
        case .testnet:
            return testnetURL
        case .sandboxnet:
            return sandboxnetURL
        }
    }
    
    var host: String? {
        var host = url.host
        if LocalUserDefaults.shared.flowNetwork == .testnet {
            host = testnetURL?.host
        }
        return host
    }

    enum CodingKeys: String, CodingKey {
        case name, url
        case testnetURL = "testnet_url"
        case sandboxnetURL = "sandboxnet_url"
        case description
        case logo, category
    }
}

struct FirebaseDAppBuildNumber: Codable {
    let build: Int
}
