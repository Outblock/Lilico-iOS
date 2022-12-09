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
    
    var iconName: String {
        return self.rawValue
    }
}

let SymbolTypeFlow: String = "flow"
let SymbolTypeFlowUSD: String = "fusd"

struct TokenModel: Codable, Identifiable {
    let name: String
    let address: FlowNetworkModel
    let contractName: String
    let storagePath: FlowTokenStoragePath
    let decimal: Int
    let icon: URL?
    let symbol: String?
    let website: URL?
    
    var isFlowCoin: Bool {
        return symbol?.lowercased() ?? "" == SymbolTypeFlow
    }
    
    var contractId: String {
        var addressString = LocalUserDefaults.shared.flowNetwork == .testnet ? address.testnet ?? "" : address.mainnet ?? ""
        addressString = addressString.stripHexPrefix()
        return "A.\(addressString).\(contractName)"
    }
    
    var id: String {
        return symbol ?? ""
    }

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
    
    var isActivated: Bool {
        if let symbol = symbol {
            return WalletManager.shared.isTokenActivated(symbol: symbol)
        }
        
        return false
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
