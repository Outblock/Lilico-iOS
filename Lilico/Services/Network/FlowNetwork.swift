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
    
    //TODO: auto be canceled,why?
    
    static func isTokenListEnabled(address: Flow.Address, tokens: [TokenModel]) -> Future<[Bool], Error> {
        flow.configure(chainID: .testnet)
        let network = flow.chainID
        let cadence =  FlowQuery.checkEnable.tokenEnableQuery(with: tokens, at: network)
        let call = flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                             arguments: [.init(value: .address(address))])
        return call
            .toFuture()
            .print("------********** 1")
            .tryMap { response in
                print("------********** tryMap")
                guard let fields = response.fields, let array = fields.value.toArray() else {
                    throw LLError.emptyWallet
                }
                return array.compactMap { $0.value.toBool() }
            }
            .print("------********** 2")
            .asFuture()
    }
    
    static func checkTokensEnable(address: Flow.Address, tokens: [TokenModel]) async throws -> [Bool] {
        //TODO: 他不应该在这里
        flow.configure(chainID: .testnet)
        let cadence =  FlowQuery.checkEnable.tokenEnableQuery(with: tokens, at:flow.chainID)
        do {
            let list = try await fetch(at: address, with: tokens, by: cadence)
            return list.map{ $0.value.toBool() ?? false }
        }catch {
            throw LLError.emptyWallet
        }
    }
    
    static func fetchBalance(at address: Flow.Address, with tokens: [TokenModel]) async throws -> [Double] {
        //TODO: 他不应该在这里
        flow.configure(chainID: .testnet)
        let cadence = FlowQuery.balance.balanceQuery(with: tokens, at: flow.chainID)
        do {
            let list = try await fetch(at: address, with: tokens, by: cadence)
            return list.map{ $0.value.toUFix64() ?? 0}
        }catch {
            throw LLError.emptyWallet
        }
    }
    
    
    private static func fetch(at address: Flow.Address, with tokens: [TokenModel], by cadence: String) async throws -> [Flow.Argument] {
        try await withCheckedThrowingContinuation { continuation in
            let call = flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                                 arguments: [.init(value: .address(address))])
            call.whenComplete { result in
                switch result {
                case let .success(response):
                    guard let fields = response.fields, let array = fields.value.toArray() else {
                        continuation.resume(throwing: LLError.emptyWallet)
                        return
                    }
                    continuation.resume(returning: array.compactMap { $0 })
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    
    
    
    
    
}

