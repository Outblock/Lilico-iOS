//
//  FlowNetwork.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Combine
import Flow
import Foundation
import BigInt

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
}

// MARK: - Token

extension FlowNetwork {
    static func checkTokensEnable(address: Flow.Address, tokens: [TokenModel]) async throws -> [Bool] {
        let cadence = TokenCadence.tokenEnable(with: tokens, at:flow.chainID)
        return try await fetch(at: address, by: cadence)
    }

    static func fetchBalance(at address: Flow.Address, with tokens: [TokenModel]) async throws -> [Double] {
        let cadence = BalanceCadence.balance(with: tokens, at: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func enableToken(at address: Flow.Address, token: TokenModel) async throws -> Flow.ID {
        let cadenceString = token.formatCadence(cadence: Cadences.addToken)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared]) {
            cadence {
                cadenceString
            }
            
            proposer {
                address
            }
            
            arguments {
                [.address(address)]
            }
        }
    }
}

// MARK: - NFT

extension FlowNetwork {
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollection]) async throws -> [Bool] {
        let cadence = NFTCadence.collectionListCheckEnabled(with: list, on: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
}

// MARK: - Others

extension FlowNetwork {
    static func addressVerify(address: String) async -> Bool {
        // testnet test address: 0x912d5440f7e3769e
        guard address.hasPrefix("0x") else {
            return false
        }

        let fAddress = Flow.Address(hex: address)
        do {
            _ = try await flow.accessAPI.getAccountAtLatestBlock(address: fAddress)
            return true
        } catch {
            return false
        }
    }
    
    static func getTransactionResult(by id: String) async throws -> Flow.TransactionResult {
        let idObj = Flow.ID(hex: id)
        return try await flow.accessAPI.getTransactionResultById(id: idObj)
    }
}

// MARK: - Base

extension FlowNetwork {
    private static func fetch<T: Decodable>(at address: Flow.Address, by cadence: String) async throws -> T {
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                                           arguments: [.address(address)])

        let model: T = try response.decode()
        return model
    }
}

// MARK: - Extension

extension Flow.TransactionResult {
    var isProcessing: Bool {
        return status < .sealed && status > .unknown
    }
    
    var isComplete: Bool {
        return status == .sealed
    }
    
    var isFailed: Bool {
        if isProcessing {
            return false
        }
        
        return status == .unknown || status == .expired
    }
}
