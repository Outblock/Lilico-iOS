//
//  RegisterResponse.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation

struct CheckUserResponse: Codable {
    let unique: Bool
    let username: String
}

struct LoginResponse: Codable {
    let customToken: String
    let id: String
}

struct RegisterResponse: Codable {
    let customToken: String
    let id: String
}

struct UserInfoResponse: Codable {
    let avatar: String
    let nickname: String
    let username: String
    let `private`: Int
}

struct UserWalletResponse: Codable {
    let id: String
    let primaryWallet: Int
    let username: String?
    let wallets: [WalletResponse]?
    
    var primaryWalletModel: WalletResponse? {
        if let wallets = wallets {
            for wallet in wallets {
                if wallet.id == primaryWallet {
                    return wallet
                }
            }
        }
        
        return nil
    }
}

struct WalletResponse: Codable {
    let color: String?
    let icon: String?
    let name: String?
    let id: Int
    let blockchain: [BlockChainResponse]?
    
    var isEmptyBlockChain: Bool {
        if let blockchain = blockchain, !blockchain.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    var getAddress: String? {
        return blockchain?.first?.address
    }
    
    var getName: String? {
        return blockchain?.first?.name
    }
}

struct BlockChainResponse: Codable {
    let id: Int
    let chainId: String
    let name: String?
    let address: String?
    let coins: [String]?
}

//struct CoinsResponse: Codable {
//    let decimal: Int
//    let isToken: Bool
//    let name: String
//    let symbol: String
//}
