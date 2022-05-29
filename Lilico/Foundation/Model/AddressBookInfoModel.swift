// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let addressBook = try? newJSONDecoder().decode(Contact.self, from: jsonData)

import Foundation

// MARK: - AddressBook
struct Contact: Codable, Identifiable {
    let address, avatar, contactName: String?
    let contactType: Int?
    let domain: Domain?
    let id: Int
    let username: String?

    enum CodingKeys: String, CodingKey {
        case address, avatar
        case contactName = "contact_name"
        case contactType = "contact_type"
        case domain, id, username
    }
}

// MARK: - Domain
struct Domain: Codable {
    let domainType: Int?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case domainType = "domain_type"
        case value
    }
}