//
//  StakingProvider.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation

struct StakingProvider: Codable {
    let description: String?
    let icon: String?
    let id: String
    let name: String
    let type: String
    let website: String?
    
    var isLilico: Bool {
        return name.lowercased() == "lilico"
    }
}
