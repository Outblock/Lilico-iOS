// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let addressBook = try? newJSONDecoder().decode(Contact.self, from: jsonData)

import Foundation

extension Contact {
    enum ContactType: Int, Codable {
        case external = 0
        case user = 1
        case domain = 2
    }
    
    enum DomainType: Int, Codable {
        case unknown = 0
        case find = 1
        case flowns = 2
    }
    
    struct Domain: Codable {
        let domainType: DomainType?
        let value: String?
    }
}

// MARK: - AddressBook
struct Contact: Codable, Identifiable {
    let address, avatar, contactName: String?
    let contactType: ContactType?
    let domain: Domain?
    let id: Int
    let username: String?
}
