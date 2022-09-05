//
//  RemoteConfig.swift
//  Lilico
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation

extension RemoteConfigManager {
    struct Config: Codable {
        let features: Features
        let payer: Payer
    }

    // MARK: - Features
    struct Features: Codable {
        let freeGas: Bool
        let walletConnect: Bool

        enum CodingKeys: String, CodingKey {
            case freeGas = "free_gas"
            case walletConnect = "wallet_connect"
        }
    }

    // MARK: - Payer
    struct Payer: Codable {
        let mainnet: PayerInfo
        let testnet: PayerInfo
    }

    // MARK: - Net
    struct PayerInfo: Codable {
        let address: String
        let keyID: Int

        enum CodingKeys: String, CodingKey {
            case address
            case keyID = "keyId"
        }
    }

}
