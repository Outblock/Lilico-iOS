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
    let `private`: Int?
    
    /// Only applicable under certain circumstances.
    /// Note: The Logged-in user did not use this.
    let address: String? = nil

    var isPrivate: Bool {
        return self.private == 2
    }
    
    func toContact() -> Contact {
        let contact = Contact(address: address, avatar: avatar, contactName: nickname, contactType: .user, domain: nil, id: UUID().hashValue, username: username)
        return contact
    }
}
