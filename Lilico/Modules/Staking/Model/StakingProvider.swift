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
    
    var iconURL: URL? {
        return URL(string: icon ?? "")
    }
    
    var apyYear: Double {
        return isLilico ? StakingManager.shared.apyYear : StakingDefaultNormalApy
    }
    
    var apyYearPercentString: String {
        let num = (apyYear * 100).formatCurrencyString(digits: 2)
        return "\(num)%"
    }
}
