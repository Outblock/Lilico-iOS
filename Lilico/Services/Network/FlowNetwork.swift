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
        let cadence = TokenQuery.tokenEnable(with: tokens, at:flow.chainID)
        return try await fetch(at: address, by: cadence)
    }

    static func fetchBalance(at address: Flow.Address, with tokens: [TokenModel]) async throws -> [Double] {
        let cadence = BlanceQuery.balance(with: tokens, at: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func enableToken(at address: Flow.Address, token: TokenModel) async throws -> Flow.ID {
        let cadence = token.formatCadence(cadence: Cadences.addToken)
        
        let account = try await flow.accessAPI.getAccountAtLatestBlock(address: address)
        guard let keyIndex = account.keys.first?.index, let sequence = account.keys.first?.sequenceNumber else {
            throw Flow.FError.invaildResponse
        }
        
        let args = [Flow.Argument]()
        let limit = BigUInt(9999)
        let payer = address
        let proposalKey = Flow.TransactionProposalKey(address: account.address, keyIndex: keyIndex, sequenceNumber: sequence)
        let refBlock = try await flow.accessAPI.getLatestBlockHeader().id
        
        let transaction = Flow.Transaction(script: Flow.Script(text: cadence),
                                           arguments: args,
                                           referenceBlockId: refBlock,
                                           gasLimit: limit,
                                           proposalKey: proposalKey,
                                           payer: payer,
                                           authorizers: [address])
        return try await flow.accessAPI.sendTransaction(transaction: transaction)
    }
}

// MARK: - NFT

extension FlowNetwork {
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollection]) async throws -> [Bool] {
        let cadence = NFTQuery.collectionListCheckEnabled(with: list, on: flow.chainID)
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
