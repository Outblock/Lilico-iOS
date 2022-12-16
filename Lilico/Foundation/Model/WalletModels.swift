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

enum ListedToken: String, CaseIterable {
    case flow
    case fusd
    case stFlow
    case usdc
    
    enum PriceAction {
        case fixed(price: Decimal)
        case query(String)
        case mirror(ListedToken)
    }
    
    var priceAction: PriceAction {
        switch self {
        case .flow:
            return .query(LocalUserDefaults.shared.market.flowPricePair)
        case .fusd:
            return .fixed(price: 1.0)
        case .stFlow:
            return .mirror(.flow)
        case .usdc:
            return .query(LocalUserDefaults.shared.market.usdcPricePair)
        }
    }
    
    init?(rawValue: String) {
        if let item = ListedToken.allCases.first(where: { $0.rawValue.lowercased() == rawValue.lowercased() }) {
            self = item
        } else {
            return nil
        }
    }
}

struct TokenModel: Codable, Identifiable {
    let name: String
    let address: FlowNetworkModel
    let contractName: String
    let storagePath: FlowTokenStoragePath
    let decimal: Int
    let icon: URL?
    let symbol: String?
    let website: URL?
    
    var listedToken: ListedToken? {
        ListedToken(rawValue: symbol ?? "")
    }
    
    var isFlowCoin: Bool {
        return symbol?.lowercased() ?? "" == ListedToken.flow.rawValue
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
        switch listedToken {
        case .flow:
            return market.flowPricePair
        case .usdc:
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
