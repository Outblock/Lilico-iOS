//
//  FlowQuery.swift
//  Lilico
//
//  Created by cat on 2022/5/2.
//

import Combine
import Flow
import Foundation

typealias TokenQuery = FlowQuery<FlowQueryAction.token>
typealias BlanceQuery = FlowQuery<FlowQueryAction.blance>
typealias NFTQuery = FlowQuery<FlowQueryAction.nft>

enum FlowQueryAction {
    enum token {}
    enum blance {}
    enum nft{}
}

struct FlowQuery<T> {}

//MARK: Check Token vault is enabled
extension FlowQuery where T == FlowQueryAction.token {
    static func tokenEnable(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        
        let cadence =
            """
              import FungibleToken from 0x9a0766d93b6608b7
              <TokenImports>
              <TokenFunctions>
              pub fun main(address: Address) : [Bool] {
                return [<TokenCall>]
              }
            """
            .replacingOccurrences(of: "<TokenImports>", with: importRow(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenEnableFunc(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenCall>", with: tokenEnableCalls(with: tokens, at: network))

        return cadence
    }

    static private func tokenEnableFunc(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
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

    static private func tokenEnableCalls(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenCalls = tokens.map { token in
            """
            check<Token>Vault(address: address)
            """
            .buildTokenInfo(token, chainId: network)
        }
        .joined(separator: ",")
        return tokenCalls
    }
}

//MARK: Get Token Balance
extension FlowQuery where T == FlowQueryAction.blance {
    
    static func balance(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let cadence =
            """
            import FungibleToken from 0x9a0766d93b6608b7
            <TokenImports>
            <TokenFunctions>
            pub fun main(address: Address) : [UFix64] {
              return [<TokenCall>]
            }
            """
            .replacingOccurrences(of: "<TokenImports>", with: importRow(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenFunctions>", with: balanceFunc(with: tokens, at: network))
            .replacingOccurrences(of: "<TokenCall>", with: balanceCalls(with: tokens, at: network))
        return cadence
    }
    
    static private func balanceFunc(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let balanceFunctions = tokens.map { token in
            """
              pub fun balance<Token>Func(address: Address) : UFix64 {
                let account = getAccount(address)
                let vaultRef = account \
                .getCapability(<TokenBalancePath>) \
                .borrow<&<Token>.Vault{FungibleToken.Balance}>() \
                ?? panic("Could not borrow Balance capability")
                return vaultRef.balance
              }
            """
                .buildTokenInfo(token, chainId: network)
        }
            .joined(separator: "\n")
        return balanceFunctions
    }
    
    static private func balanceCalls(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let balanceCalls =  tokens.map { token in
            """
            balance<Token>Func(address: address)
            """
                .buildTokenInfo(token, chainId: network)
        }
            .joined(separator: ",")
        return balanceCalls
    }
    
}

//MARK: Body of Check Token vault is enabled
extension FlowQuery {
    
    static private func importRow(with tokens: [TokenModel], at network: Flow.ChainID) -> String {
        let tokenImports = tokens.map { token in
            """
            import <Token> from <TokenAddress>
            
            """
                .buildTokenInfo(token, chainId: network)
        }.joined(separator: "\r\n")
        return tokenImports
    }
    
}

//MARK: NFT

extension FlowQuery where T == FlowQueryAction.nft {
    
    static func collectionListCheckEnabled(with list: [NFTCollection], at network: Flow.ChainID) -> String {
        let tokenImports = list.map {
            $0.formatCadence(script: "import <Token> from <TokenAddress>")
        }.joined(separator: "\r\n")

        let tokenFunctions = list.map {
            $0.formatCadence(script:
                """
                pub fun check<Token>Vault(address: Address) : Bool {
                                let account = getAccount(address)
                                let vaultRef = account
                                .getCapability<&{NonFungibleToken.CollectionPublic}>(<TokenCollectionPublicPath>)
                                .check()
                                return vaultRef
                            }
                """
            )
        }.joined(separator: "\r\n")

        let tokenCalls = list.map {
            $0.formatCadence(script:
                """
                check<Token>Vault(address: address)
                """
            )
        }.joined(separator: ",")

        let cadence =
            """
            import NonFungibleToken from 0xNonFungibleToken
                      <TokenImports>
                      <TokenFunctions>
                      pub fun main(address: Address) : [Bool] {
                        return [<TokenCall>]
                    }
            """
            .replacingOccurrences(of: "<TokenFunctions>", with: tokenFunctions)
            .replacingOccurrences(of: "<TokenImports>", with: tokenImports)
            .replacingOccurrences(of: "<TokenCall>", with: tokenCalls)
        return cadence
    }
}

extension String {
    func buildTokenInfo(_ token: TokenModel, chainId: Flow.ChainID) -> String {
        return replacingOccurrences(of: "<Token>", with: token.contractName)
            .replacingOccurrences(of: "<TokenAddress>", with: token.address.addressByNetwork(chainId) ?? "0x")
            .replacingOccurrences(of: "<TokenBalancePath>", with: token.storagePath.balance)
            .replacingOccurrences(of: "<TokenReceiverPath>", with: token.storagePath.receiver)
            .replacingOccurrences(of: "<TokenStoragePath>", with: token.storagePath.vault)
    }
}

extension NFTCollection {
    func formatCadence(script: String) -> String {
        return script
            .replacingOccurrences(of: "<NFT>", with: contractName)
            .replacingOccurrences(of: "<NFTAddress>", with: address(mainnet: false))
            .replacingOccurrences(of: "<CollectionStoragePath>", with: path.storagePath)
            .replacingOccurrences(of: "<CollectionPublic>", with: path.publicCollectionName)
            .replacingOccurrences(of: "<CollectionPublicPath>", with: path.publicPath)
            .replacingOccurrences(of: "<Token>", with: contractName)
            .replacingOccurrences(of: "<TokenAddress>", with: address(mainnet: false))
            .replacingOccurrences(of: "<TokenCollectionStoragePath>", with: path.storagePath)
            .replacingOccurrences(of: "<TokenCollectionPublic>", with: path.publicCollectionName)
            .replacingOccurrences(of: "<TokenCollectionPublicPath>", with: path.publicPath)
    }
}
