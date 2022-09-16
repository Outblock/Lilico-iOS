//
//  FlownsResponses.swift
//  Lilico
//
//  Created by Selina on 16/9/2022.
//

import Foundation

struct ClaimDomainPrepareResponse: Codable {
    let cadence: String?
    let domain: String?
    let flownsServerAddress: String?
    let lilicoServerAddress: String?
}

struct ClaimDomainSignatureResponse: Codable {
    let txId: String?
}
