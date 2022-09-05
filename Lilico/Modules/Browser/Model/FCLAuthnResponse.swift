//
//  FCLAuthnResponse.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit

struct FCLAuthnResponse: Codable, FCLResponseProtocol {
    let body: Body
    let service: FCLSimpleService
    let config: FCLResponseConfig?
    let type: String
    
    func uniqueId() -> String {
        return "\(service.type.rawValue)-\(type)"
    }
}

extension FCLAuthnResponse {
    struct Body: Codable {
        let extensions: [FCLExtension]?
        let timestamp: TimeInterval?
        let appIdentifier: String?
        let nonce: String?
    }
}
