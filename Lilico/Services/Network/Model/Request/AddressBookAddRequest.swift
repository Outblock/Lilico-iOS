//
//  AddressBookAddRequest.swift
//  Lilico
//
//  Created by Selina on 2/6/2022.
//

import Foundation

struct AddressBookAddRequest: Codable {
    let contactName: String
    let address: String
    let domain: String?
    let domainType: Int
    let username: String?
}
