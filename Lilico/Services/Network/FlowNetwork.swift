//
//  FlowNetwork.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Foundation
import Flow
import Combine

class FlowNetwork {
    
    static func setup() {
        if LocalUserDefaults.shared.flowNetwork == .testnet {
            debugPrint("did setup flow chainID to testnet")
            flow.configure(chainID: .testnet)
        } else {
            debugPrint("did setup flow chainID to mainnet")
            flow.configure(chainID: .mainnet)
        }
    }
    
    static func checkTokensEnable(address: Flow.Address, tokens: [TokenModel]) async throws -> [Bool] {
        let cadence = FlowQuery.checkEnable.tokenEnableQuery(with: tokens, at:flow.chainID)
        let test: [Bool] = try await fetch(at: address, by: cadence)
        return test
    }
    
    static func fetchBalance(at address: Flow.Address, with tokens: [TokenModel]) async throws -> [Double] {
        let cadence = FlowQuery.balance.balanceQuery(with: tokens, at: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func addressVerify(address: String) async -> Bool {
        // testnet test address: 0x912d5440f7e3769e
        guard address.hasPrefix("0x") else {
            return false
        }

        let fAddress = Flow.Address(hex: address)
        do {
            let _ = try await flow.accessAPI.getAccountAtLatestBlock(address: fAddress)
            return true
        } catch {
            return false
        }
    }
    
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollection]) async throws -> [Bool] {
        let cadence = FlowQuery.nft.NFTCollectionListCheckEnabledQuery(with: list, at:flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    private static func fetch<T: Decodable>(at address: Flow.Address, by cadence: String) async throws -> T {
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                                           arguments: [.address(address)])
        
        let model: T = try response.decode()
        return model
    }
}

