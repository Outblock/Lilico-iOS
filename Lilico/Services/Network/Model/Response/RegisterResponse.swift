//
//  RegisterResponse.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation

/*
 {
   "custom_token": "string",
   "id": "string"
 }
 */

struct RegisterResponse: Codable {
    let customToken: String
    let id: String
}

struct UserInfoResponse: Codable {
    let avatar: String
    let nickname: String
    let username: String
    let `private`: Bool
}

struct UserWalletResponse: Codable {
    let id: String
    let primaryWallet: Int
    let username: String?
    let wallets: [WalletResponse]?
}

struct WalletResponse: Codable {
    let color: String?
    let icon: String?
    let name: String?
    let id: Int
    let blockchain: [BlockChainResponse]?
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
