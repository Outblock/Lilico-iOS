//
//  StakingManager.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation
import SwiftUI

let StakingDefaultApy: Double = 0.093
let StakingDefaultNormalApy: Double = 0.08

class StakingManager: ObservableObject {
    static let shared = StakingManager()
    
    @Published var apy: Double = StakingDefaultApy
    @Published var apyYear: Double = StakingDefaultApy
    
    init() {
        _ = StakingProviderCache.cache
        
        if let apyCache = LocalUserDefaults.shared.stakingApy {
            self.apy = apyCache
        }
        
        if let apyYearCache = LocalUserDefaults.shared.stakingApyYear {
            self.apyYear = apyYearCache
        }
    }
    
    private func updateApy() {
        Task {
            do {
                if let apy = try await FlowNetwork.getStakingApyByWeek() {
                    DispatchQueue.main.async {
                        self.apy = apy
                        LocalUserDefaults.shared.stakingApy = apy
                    }
                }
                
                if let apyYear = try await FlowNetwork.getStakingApyByYear() {
                    DispatchQueue.main.async {
                        self.apyYear = apyYear
                        LocalUserDefaults.shared.stakingApyYear = apyYear
                    }
                }
            } catch {
                debugPrint("StakingManager -> updateApy failed: \(error)")
            }
        }
    }
}
