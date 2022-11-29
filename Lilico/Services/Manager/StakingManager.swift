//
//  StakingManager.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation

class StakingManager {
    static let shared = StakingManager()
    
    init() {
        _ = StakingProviderCache.cache
    }
}
