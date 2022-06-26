//
//  TokenModel.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Flow
import Foundation

// MARK: - Coin

enum QuoteMarket: String {
    case binance
    case kraken
    case huobi

    var flowPricePair: String {
        switch self {
        case .kraken:
            return "flowusd"
        default:
            return "flowusdt"
        }
    }

    var usdcPricePair: String {
        switch self {
        case .kraken:
            return "usdcusd"
        default:
            return "usdcusdt"
        }
    }
}

let SymbolTypeFlow: String = "flow"
let SymbolTypeFlowUSD: String = "fusd"

struct TokenModel: Codable {
    let name: String
    let address: FlowNetworkModel
    let contractName: String
    let storagePath: FlowTokenStoragePath
    let decimal: Int
    let icon: URL?
    let symbol: String?
    let website: URL?

    func getAddress() -> String? {
        return address.addressByNetwork(LocalUserDefaults.shared.flowNetwork.toFlowType())
    }

    func getPricePair(market: QuoteMarket) -> String {
        switch symbol {
        case SymbolTypeFlow:
            return market.flowPricePair
        case SymbolTypeFlowUSD:
            return market.usdcPricePair
        default:
            return ""
        }
    }
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