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
    private let cacheKey = "StakingManager"
    
    @Published var info: StakingInfo = StakingInfo()
    @Published var delegatorIds: [String: Int] = [:]
    @Published var apy: Double = StakingDefaultApy
    @Published var apyYear: Double = StakingDefaultApy
    @Published var isSetup: Bool = false
    
    var stakingCount: Double {
        var count: Double = 0
        return info.nodes.reduce(0.0) { partialResult, node in
            partialResult + node.tokensCommitted + node.tokensStaked
        }
    }
    
    var isStaked: Bool {
        if info.nodes.isEmpty {
            refresh()
        }
        
        return stakingCount > 0
    }
    
    init() {
        _ = StakingProviderCache.cache
        loadCache()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
    }
    
    func refresh() {
        updateApy()
        updateSetupStatus()
        queryStakingInfo()
        Task {
            do {
                try await refreshDelegatorInfo()
            } catch {
                debugPrint("StakingManager -> refreshDelegatorInfo failed: \(error)")
            }
        }
    }
    
    func stakingSetup() async -> Bool {
        do {
            if try await FlowNetwork.accountStakingIsSetup() == true {
                // has been setup
                return true
            }
            
            let isSetup = try await FlowNetwork.setupAccountStaking()
            DispatchQueue.main.sync {
                self.isSetup = isSetup
                self.saveCache()
            }
            
            return isSetup
        } catch {
            debugPrint("StakingManager -> stakingSetup failed: \(error)")
            return false
        }
    }
}

extension StakingManager {
    private func updateApy() {
        Task {
            do {
                if let apy = try await FlowNetwork.getStakingApyByWeek() {
                    DispatchQueue.main.async {
                        self.apy = apy
                        self.saveCache()
                    }
                }
                
                if let apyYear = try await FlowNetwork.getStakingApyByYear() {
                    DispatchQueue.main.async {
                        self.saveCache()
                    }
                }
            } catch {
                debugPrint("StakingManager -> updateApy failed: \(error)")
            }
        }
    }
    
    private func queryStakingInfo() {
        Task {
            do {
                if let response = try await FlowNetwork.queryStakeInfo() {
                    DispatchQueue.main.async {
                        self.info = response
                        self.saveCache()
                    }
                }
            } catch {
                debugPrint("StakingManager -> queryStakingInfo failed: \(error)")
            }
        }
    }
    
    func refreshDelegatorInfo() async throws {
        if let response = try await FlowNetwork.getDelegatorInfo(), !response.isEmpty {
            DispatchQueue.main.sync {
                self.delegatorIds = response
            }
        }
    }
    
    private func updateSetupStatus() {
        Task {
            do {
                let isSetup = try await FlowNetwork.accountStakingIsSetup()
                DispatchQueue.main.async {
                    self.isSetup = isSetup
                    self.saveCache()
                }
            } catch {
                debugPrint("StakingManager -> updateSetupStatus failed: \(error)")
            }
        }
    }
    
    @objc private func willReset() {
        self.info = StakingInfo()
        self.delegatorIds.removeAll()
        self.apy = StakingDefaultApy
        self.apyYear = StakingDefaultApy
        self.isSetup = false
    }
}

extension StakingManager {
    struct StakingCache: Codable {
        var info: StakingInfo?
        var apy: Double = StakingDefaultApy
        var apyYear: Double = StakingDefaultApy
        var isSetup: Bool = false
    }
    
    private func saveCache() {
        let cacheObj = StakingCache(info: info, apy: apy, apyYear: apyYear, isSetup: isSetup)
        PageCache.cache.set(value: cacheObj, forKey: cacheKey)
    }
    
    private func loadCache() {
        Task {
            do {
                let cacheObj = try await PageCache.cache.get(forKey: cacheKey, type: StakingCache.self)
                if let info = cacheObj.info {
                    self.info = info
                }
                self.apy = cacheObj.apy
                self.apyYear = cacheObj.apyYear
                self.isSetup = cacheObj.isSetup
            } catch {
                
            }
        }
    }
}
