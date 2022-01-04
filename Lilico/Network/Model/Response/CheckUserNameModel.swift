//
//  CheckUserNameModel.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation

/*
 {
   "unique": true,
   "user_name": "string"
 }
 */

struct CheckUserNameModel: Codable {
    let unique: Bool
    let userName: String
}
