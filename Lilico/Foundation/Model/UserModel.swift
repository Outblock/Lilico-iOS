//
//  UserModel.swift
//  Lilico
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI

struct UserInfo: Codable {
    let avatar: String
    let nickname: String
    let username: String
    let `private`: Int
    
    var isPrivate: Bool {
        return self.private == 2
    }
}
