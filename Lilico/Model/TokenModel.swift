//
//  TokenModel.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Foundation
import Flow

struct TokenModel: Codable {
  let name: String
  let address: FlowNetworkModel
  let contractName: String
  let storagePath: FlowTokenStoragePath
  let decimal: Int
  let icon: URL?
  let symbol: URL?
  let website: URL?
}

struct FlowNetworkModel: Codable {
    let mainnet: String?
    let testnet: String?
    
    func addressByNetwork(_ network: Flow.ChainID) -> String? {
        switch network {
        case .mainnet:
            return mainnet
        case .testnet:
            return testnet
        default:
            return nil
        }
    }
}

struct FlowTokenStoragePath: Codable {
  let balance: String
  let vault: String
  let receiver: String
}
