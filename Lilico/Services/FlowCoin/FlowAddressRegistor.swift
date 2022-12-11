//
//  FlowAddressRegistor.swift
//  Lilico
//
//  Created by Hao Fu on 26/6/2022.
//

import Foundation
import Flow

enum ScriptAddress: String, CaseIterable {
    case fungibleToken = "0xFungibleToken"
    case flowToken = "0xFlowToken"
    case flowFees = "0xFlowFees"
    case flowTablesTaking = "0xFlowTableStaking"
    case lockedTokens = "0xLockedTokens"
    case stakingProxy = "0xStakingProxy"
    case nonFungibleToken = "0xNonFungibleToken"
    case findToken = "0xFind"
    case domainsToken = "0xDomains"
    case flownsToken = "0xFlowns"
    case metadataViews = "0xMetadataViews"
    case stakingCollection = "0xStakingCollection"
    case flowIDTableStaking = "0xFlowIDTableStaking"
    
    static func addressMap(on network: LocalUserDefaults.FlowNetworkType = LocalUserDefaults.shared.flowNetwork) -> [String: String] {
        let dict = ScriptAddress.allCases.reduce(into: [String: String]()) { partialResult, script in
            partialResult[script.rawValue] = script.address(on: network).hex.withPrefix()
        }
        return dict
    }
    
    func address(on network: LocalUserDefaults.FlowNetworkType = LocalUserDefaults.shared.flowNetwork ) -> Flow.Address {
        switch (self, network) {
            // Mainnet
        case (.fungibleToken, .mainnet):
            return Flow.Address(hex: "0xf233dcee88fe0abe")
        case (.flowToken, .mainnet):
            return Flow.Address(hex: "0x1654653399040a61")
        case (.flowFees, .mainnet):
            return Flow.Address(hex: "0xf919ee77447b7497")
        case (.flowTablesTaking, .mainnet):
            return Flow.Address(hex: "0x8624b52f9ddcd04a")
        case (.lockedTokens, .mainnet):
            return Flow.Address(hex: "0x8d0e87b65159ae63")
        case (.stakingProxy, .mainnet):
            return Flow.Address(hex: "0x62430cf28c26d095")
        case (.nonFungibleToken, .mainnet):
            return Flow.Address(hex: "0x1d7e57aa55817448")
        case (.findToken, .mainnet):
            return Flow.Address(hex: "0x097bafa4e0b48eef")
        case (.domainsToken, .mainnet):
            return Flow.Address(hex: "0x233eb012d34b0070")
        case (.flownsToken, .mainnet):
            return Flow.Address(hex: "0x233eb012d34b0070")
        case (.metadataViews, .mainnet):
            return Flow.Address(hex: "0x1d7e57aa55817448")
        case (.stakingCollection, .mainnet):
            return Flow.Address(hex: "0x8d0e87b65159ae63")
        case (.flowIDTableStaking, .mainnet):
            return Flow.Address(hex: "0x8624b52f9ddcd04a")
            
            // Testnet
        case (.fungibleToken, .testnet):
            return Flow.Address(hex: "0x9a0766d93b6608b7")
        case (.flowToken, .testnet):
            return Flow.Address(hex: "0x7e60df042a9c0868")
        case (.flowFees, .testnet):
            return Flow.Address(hex: "0x912d5440f7e3769e")
        case (.flowTablesTaking, .testnet):
            return Flow.Address(hex: "0x9eca2b38b18b5dfe")
        case (.lockedTokens, .testnet):
            return Flow.Address(hex: "0x95e019a17d0e23d7")
        case (.stakingProxy, .testnet):
            return Flow.Address(hex: "0x7aad92e5a0715d21")
        case (.nonFungibleToken, .testnet):
            return Flow.Address(hex: "0x631e88ae7f1d7c20")
        case (.findToken, .testnet):
            return Flow.Address(hex: "0xa16ab1d0abde3625")
        case (.domainsToken, .testnet):
            return Flow.Address(hex: "0xb05b2abb42335e88")
        case (.flownsToken, .testnet):
            return Flow.Address(hex: "0xb05b2abb42335e88")
        case (.metadataViews, .testnet):
            return Flow.Address(hex: "0x631e88ae7f1d7c20")
        case (.stakingCollection, .testnet):
            return Flow.Address(hex: "0x95e019a17d0e23d7")
        case (.flowIDTableStaking, .testnet):
            return Flow.Address(hex: "0x9eca2b38b18b5dfe")
        }
    }
}
