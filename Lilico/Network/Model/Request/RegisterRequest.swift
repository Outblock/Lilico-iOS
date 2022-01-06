//
//  RegisterRequest.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation

struct RegisterReuqest: Codable {
    let username: String
    let accountKey: AccountKey
}

struct AccountKey: Codable {
    let hashAlgo: Int
    let publicKey: String
    let sign_algo: Int
    var weight: Int = 1000
}
