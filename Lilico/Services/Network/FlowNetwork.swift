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
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared]) {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
            }
            
            authorizers {
                address
            }
            
            gasLimit {
                9999
            }
        }
    }
    
    static func transferToken(to address: Flow.Address, amount: Double) async throws -> Flow.ID {
        let cadenceString = Cadences.transferToken.replace(by: ScriptAddress.addressMap())
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
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
            
            gasLimit {
                9999
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
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                address
            }
            
            authorizers {
                address
            }
            
            gasLimit {
                9999
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
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
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
        var realDomain = domain
            .replacingOccurrences(of: ".fn", with: "")
            .replacingOccurrences(of: ".meow", with: "")
        return try await fetch(cadence: cadence, arguments: [.string(realDomain), .string(root)])
    }
}

// MARK: - Inbox

extension FlowNetwork {
    static func claimInboxToken(domain: String, key: String, coin: TokenModel, amount: Double, root: String = Contact.DomainType.meow.domain) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        let cadenceString = coin.formatCadence(cadence: Cadences.claimInboxToken)
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                [.string(domain), .string(root), .string(key), .ufix64(amount)]
            }
            
            gasLimit {
                9999
            }
        })
    }
    
    static func claimInboxNFT(domain: String, key: String, collection: NFTCollectionInfo, itemId: UInt64, root: String = Contact.DomainType.meow.domain) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        let cadenceString = collection.formatCadence(script: Cadences.claimInboxNFT)
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                [.string(domain), .string(root), .string(key), .uint64(itemId)]
            }
            
            gasLimit {
                9999
            }
        })
    }
}

// MARK: - Swap

extension FlowNetwork {
    static func swapToken(swapPaths: [String], tokenInMax: Double, tokenOutMin: Double, tokenInVaultPath: String, tokenOutSplit: [Double], tokenInSplit: [Double], tokenOutVaultPath: String, tokenOutReceiverPath: String, tokenOutBalancePath: String, deadline: Double, isFrom: Bool) async throws -> Flow.ID {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        
        let tokenName = String(swapPaths.last?.split(separator: ".").last ?? "")
        let tokenAddress = String(swapPaths.last?.split(separator: ".")[1] ?? "").addHexPrefix()
        
        var cadenceString = isFrom ? Cadences.swapFromTokenToOtherToken : Cadences.swapOtherTokenToFromToken
        cadenceString = cadenceString.replace(by: ["Token1Name": tokenName, "Token1Addr": tokenAddress])
        
        var args = [Flow.Cadence.FValue]()
        args.append(.array(swapPaths.map { Flow.Argument(value: .string($0)) }))
        
        if isFrom {
            args.append(.array(tokenInSplit.map { Flow.Argument(value: .ufix64($0)) }))
            args.append(.ufix64(tokenOutMin))
        } else {
            args.append(.array(tokenOutSplit.map { Flow.Argument(value: .ufix64($0)) }))
            args.append(.ufix64(tokenInMax))
        }
        
        args.append(.ufix64(deadline))
        args.append(.path(Flow.Argument.Path(domain: "storage", identifier: tokenInVaultPath)))
        args.append(.path(Flow.Argument.Path(domain: "storage", identifier: tokenOutVaultPath)))
        args.append(.path(Flow.Argument.Path(domain: "public", identifier: tokenOutReceiverPath)))
        args.append(.path(Flow.Argument.Path(domain: "public", identifier: tokenOutBalancePath)))
        
        return try await flow.sendTransaction(signers: [WalletManager.shared, RemoteConfigManager.shared], builder: {
            cadence {
                cadenceString
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
            
            proposer {
                Flow.Address(hex: address)
            }
            
            authorizers {
                Flow.Address(hex: address)
            }
            
            arguments {
                args
            }
            
            gasLimit {
                9999
            }
        })
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
    
    static func getAccountAtLatestBlock(address: String) async throws -> Flow.Account {
        return try await flow.accessAPI.getAccountAtLatestBlock(address: Flow.Address(hex: address))
    }
    
    static func getLastBlockAccountKeyId(address: String) async throws -> Int {
        let account = try await getAccountAtLatestBlock(address: address)
        return account.keys.first?.index ?? 0
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
