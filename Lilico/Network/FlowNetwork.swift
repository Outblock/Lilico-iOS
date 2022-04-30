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
    var network: Flow.ChainID
    var accessAPI: Flow.AccessAPI
    
    init() {
        // TODO: Replace me, need change chainID by config
        network = .testnet
        accessAPI = flow.createAccessAPI(chainID: network)
    }
    
    func changeNetwork(network: Flow.ChainID) {
        if network == self.network {
            return
        }
        
        self.network = network
        accessAPI = flow.createAccessAPI(chainID: network)
    }
    
    func isTokenListEnabled(address: Flow.Address, tokens: [TokenModel]) -> Future<[Bool], Error> {
        let tokenImports = tokens.map { token in
            """
            import <Token> from <TokenAddress>
            """
            .replaceTokenInfo(token, network: network)
        }.joined(separator: "\r\n")
        
        let tokenFunctions = tokens.map { token in
            """
              pub fun check<Token>Vault(address: Address) : Bool {
                let receiver: Bool = getAccount(address)
                .getCapability<&<Token>.Vault{FungibleToken.Receiver}>(<TokenReceiverPath>)
                .check()
                let balance: Bool = getAccount(address)
                 .getCapability<&<Token>.Vault{FungibleToken.Balance}>(<TokenBalancePath>)
                 .check()
                 return receiver && balance
              }
            """
                .replaceTokenInfo(token, network: network)
        }.joined(separator: "\r\n")
        
        let tokenCalls =  tokens.map { token in
            """
            check<Token>Vault(address: address)
            """
            .replaceTokenInfo(token, network: network)
        }.joined(separator: ",")
        
        let cadence =  """
              import FungibleToken from 0xFungibleToken
              <TokenImports>
              <TokenFunctions>
              pub fun main(address: Address) : [Bool] {
                return [<TokenCall>]
              }
            """
            .replacingOccurrences(of: "<TokenImports>", with: tokenImports)
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenFunctions)
            .replacingOccurrences(of: "<TokenCall>", with: tokenCalls)
        
        
        
        let call = accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                        arguments: [.init(value: .address(address))])
        
//        return Future { promise in
//            call.whenComplete { result in
//                switch result {
//                case let .success(response):
//                    guard let fields = response.fields, let array = fields.value.toArray() else {
//                        promise(.failure(LLError.emptyWallet))
//                        return
//                    }
//                    let list = array.compactMap { $0.value.toBool() }
//                    promise(.success(list))
//                case let .failure(error):
//                    promise(.failure(error))
//                }
//            }
//        }
        
        return call
            .toFuture()
            .tryMap { response in
                guard let fields = response.fields, let array = fields.value.toArray() else {
                    throw LLError.emptyWallet
                }
                return array.compactMap { $0.value.toBool() }
            }
            .asFuture()
    }
}

extension String {
    func replaceTokenInfo(_ token: TokenModel, network: Flow.ChainID) -> String {
        return self
            .replacingOccurrences(of: "<Token>", with: token.contractName)
            .replacingOccurrences(of: "<TokenAddress>", with: token.address.addressByNetwork(network) ?? "0x")
            .replacingOccurrences(of: "<TokenBalancePath>", with: token.storagePath.balance)
            .replacingOccurrences(of: "<TokenReceiverPath>", with: token.storagePath.receiver)
            .replacingOccurrences(of: "<TokenStoragePath>", with: token.storagePath.vault)
    }
}
