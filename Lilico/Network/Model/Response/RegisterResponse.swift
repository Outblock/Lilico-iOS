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
    let nickName: String
}

struct UserWalletResponse: Codable {
    let id: String
    let primaryWallet: Int
    let userName: String
    let wallet: [WalletResponse]?
}

struct WalletResponse: Codable {
    let color: String
    let icon: String
    let name: String
    let walletId: Int
    let blockchain: [BlockchainResponse]
}

struct BlockchainResponse: Codable {
    let name: String
    let address: String
    let blockchainId: Int
}

struct CoinsResponse: Codable {
    let decimal: Int
    let isToken: Bool
    let name: String
    let symbol: String
}
