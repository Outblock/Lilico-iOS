//
//  FlowQuery.swift
//  Lilico
//
//  Created by cat on 2022/5/2.
//

import Foundation
import Flow
import Combine

enum FlowQuery {
    case checkEnable
}

extension FlowQuery {
    //MARK: Check Token vault is enabled
    func tokenEnable(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        if(self != .checkEnable) {
            print("Error: the case(\(self) is not call the func \(#function)")
            return ""
        }
        
        let cadence =  """
                     import FungibleToken from 0x9a0766d93b6608b7
                     <TokenImports>
                     <TokenFunctions>
                     pub fun main(address: Address) : [Bool] {
                       return [<TokenCall>]
                     }
                   """
                   .replacingOccurrences(of: "<TokenImports>", with: tokenImports(with: tokens, at: network))
                   .replacingOccurrences(of: "<TokenFunctions>", with: tokenFunc(with: tokens, at: network))
                   .replacingOccurrences(of: "<TokenCall>", with: tokenCalls(with: tokens, at: network))
        
        return cadence
    }
    
    
}

//MARK: 拼接参数
extension FlowQuery {
    
    private func tokenImports(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenImports = tokens.map { token in
            """
            import <Token> from <TokenAddress>
            
            """
            .buildTokenInfo(token, chainId: network)
        }.joined(separator: "\n")
        return tokenImports
    }
    
    private func tokenFunc(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenFunctions = tokens.map { token in
            """
              pub fun check<Token>Vault(address: Address) : Bool {
                let receiver: Bool = getAccount(address) \
                .getCapability<&<Token>.Vault{FungibleToken.Receiver}>(<TokenReceiverPath>) \
                .check()
                let balance: Bool = getAccount(address) \
                 .getCapability<&<Token>.Vault{FungibleToken.Balance}>(<TokenBalancePath>) \
                 .check()
                 return receiver && balance
              }
            
            """
            .buildTokenInfo(token, chainId: network)
        }.joined(separator: "\n")
        return tokenFunctions
    }
    
    private func tokenCalls(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenCalls =  tokens.map { token in
            """
            check<Token>Vault(address: address)
            """
            .buildTokenInfo(token, chainId: network)
        }.joined(separator: ",")
        return tokenCalls
    }
}


extension String {
    func buildTokenInfo(_ token: TokenModel, chainId: Flow.ChainID) -> String {
        return self
            .replacingOccurrences(of: "<Token>", with: token.contractName)
            .replacingOccurrences(of: "<TokenAddress>", with: token.address.addressByNetwork(chainId) ?? "0x")
            .replacingOccurrences(of: "<TokenBalancePath>", with: token.storagePath.balance)
            .replacingOccurrences(of: "<TokenReceiverPath>", with: token.storagePath.receiver)
            .replacingOccurrences(of: "<TokenStoragePath>", with: token.storagePath.vault)
    }
}
