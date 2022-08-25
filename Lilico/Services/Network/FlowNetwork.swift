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
            
            authorizers {
                address
            }
        }
    }
    
    static func transferToken(to address: Flow.Address, amount: Double) async throws -> Flow.ID {
        let cadenceString = Cadences.transferToken.replace(by: ScriptAddress.addressMap())
        
        return try await flow.sendTransaction(signers: [WalletManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                WalletManager.shared.getPrimaryWalletAddress() ?? ""
            }
            
            proposer {
                WalletManager.shared.getPrimaryWalletAddress() ?? ""
            }
            
            authorizers {
                Flow.Address(hex: WalletManager.shared.getPrimaryWalletAddress() ?? "")
            }
            
            arguments {
                [.ufix64(amount), .address(address)]
            }
        })
    }
}

// MARK: - NFT

extension FlowNetwork {
    static func checkCollectionEnable(address: Flow.Address, list: [NFTCollectionInfo]) async throws -> [Bool] {
        let cadence = NFTCadence.collectionListCheckEnabled(with: list, on: flow.chainID)
        return try await fetch(at: address, by: cadence)
    }
    
    static func addCollection(at address: Flow.Address, collection: NFTCollectionInfo) async throws -> Flow.ID {
        let cadenceString = collection.formatCadence(script: Cadences.nftCollectionEnable)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            proposer {
                address
            }
            
            authorizers {
                address
            }
        })
    }
    
    static func transferNFT(to address: Flow.Address, nft: NFTModel) async throws -> Flow.ID {
        guard let collection = nft.collection else {
            throw NFTError.noCollectionInfo
        }
        
        guard let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        guard let tokenIdInt = UInt64(nft.response.id.tokenID) else {
            throw NFTError.invalidTokenId
        }
        
        let cadenceString = collection.formatCadence(script: Cadences.nftTransfer)
        
        return try await flow.sendTransaction(signers: [WalletManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            proposer {
                Flow.Address(hex: fromAddress)
            }
            
            authorizers {
                Flow.Address(hex: fromAddress)
            }
            
            arguments {
                [.address(address), .uint64(tokenIdInt)]
            }
            
            gasLimit {
                9999
            }
        })
    }
}

// MARK: - Search

extension FlowNetwork {
    static func queryAddressByDomainFind(domain: String) async throws -> String {
        let cadence = Cadences.queryAddressByDomainFind
        return try await fetch(cadence: cadence, arguments: [.string(domain)])
    }
    
    static func queryAddressByDomainFlowns(domain: String, root: String = "fn") async throws -> String {
        let cadence = Cadences.queryAddressByDomainFlowns
        return try await fetch(cadence: cadence, arguments: [.string(domain), .string(root)])
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
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence),
                                                                           arguments: [.address(address)])

        let model: T = try response.decode()
        return model
    }
    
    private static func fetch<T: Decodable>(cadence: String, arguments: [Flow.Cadence.FValue]) async throws -> T {
        let replacedCadence = cadence.replace(by: ScriptAddress.addressMap())
        
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: replacedCadence), arguments: arguments)
        let model: T = try response.decode()
        return model
    }
}

// MARK: - Extension

extension Flow.TransactionResult {
    var isProcessing: Bool {
        return status < .sealed && errorMessage.isEmpty
    }
    
    var isComplete: Bool {
        return status == .sealed && errorMessage.isEmpty
    }
    
    var isFailed: Bool {
        if isProcessing {
            return false
        }
        
        return !errorMessage.isEmpty
    }
}
