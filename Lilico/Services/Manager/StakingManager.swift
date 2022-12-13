//
//  StakingManager.swift
//  Lilico
//
//  Created by Selina on 30/11/2022.
//

import Foundation
import SwiftUI
import Combine

let StakingDefaultApy: Double = 0.093
let StakingDefaultNormalApy: Double = 0.08

// 2022-10-27 07:00
private let StakeStartTime: TimeInterval = 1666825200
private let StakingGapSeconds: TimeInterval = 7 * 24 * 60 * 60

class StakingManager: ObservableObject {
    static let shared = StakingManager()
    
    private lazy var rootFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("staking_cache")
    private lazy var cacheFile = rootFolder.appendingPathComponent("cache_file")
    
    @Published var nodeInfos: [StakingNode] = []
    @Published var delegatorIds: [String: Int] = [:]
    @Published var apy: Double = StakingDefaultApy
    @Published var isSetup: Bool = false
    
    private var cancelSet = Set<AnyCancellable>()
    
    var stakingCount: Double {
        return nodeInfos.reduce(0.0) { partialResult, node in
            partialResult + node.tokensCommitted + node.tokensStaked
        }
    }
    
    var dayRewards: Double {
        let yearTotalRewards = nodeInfos.reduce(0.0) { partialResult, node in
            let apy = node.isLilico ? apy : StakingDefaultNormalApy
            return partialResult + (node.stakingCount * apy)
        }
        
        return yearTotalRewards / 365.0
    }
    
    var monthRewards: Double {
        return dayRewards * 30
    }
    
    var dayRewardsASUSD: Double {
        let coinRate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return dayRewards * coinRate
    }
    
    var monthRewardsASUSD: Double {
        let coinRate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return monthRewards * coinRate
    }
    
    var isStaked: Bool {
        return stakingCount > 0
    }
    
    var stakingEpochStartTime: Date {
        let current = Date().timeIntervalSince1970
        var startTime = StakeStartTime
        while startTime + StakingGapSeconds < current {
            startTime += StakingGapSeconds
        }
        
        return Date(timeIntervalSince1970: startTime)
    }
    
    var stakingEpochEndTime: Date {
        return stakingEpochStartTime.addingTimeInterval(StakingGapSeconds)
    }
    
    func providerForNodeId(_ nodeId: String) -> StakingProvider? {
        return StakingProviderCache.cache.providers.first { $0.id == nodeId }
    }
    
    init() {
        _ = StakingProviderCache.cache
        createFolderIfNeeded()
        loadCache()
        
        UserManager.shared.$isLoggedIn.sink { _ in
            DispatchQueue.main.async {
                if UserManager.shared.isLoggedIn == false {
                    self.willReset()
                }
            }
        }.store(in: &cancelSet)
    }
    
    func refresh() {
        if !UserManager.shared.isLoggedIn {
            return
        }
        
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
                        debugPrint("StakingManager -> queryStakingInfo success")
                        self.nodeInfos = response
                        self.saveCache()
                    }
                } else {
                    debugPrint("StakingManager -> queryStakingInfo is empty")
                }
            } catch {
                debugPrint("StakingManager -> queryStakingInfo failed: \(error)")
            }
        }
    }
    
    func refreshDelegatorInfo() async throws {
        if let response = try await FlowNetwork.getDelegatorInfo(), !response.isEmpty {
            debugPrint("StakingManager -> refreshDelegatorInfo success, \(response)")
            DispatchQueue.main.sync {
                self.delegatorIds = response
            }
        } else {
            debugPrint("StakingManager -> refreshDelegatorInfo is empty")
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
        self.nodeInfos = []
        self.delegatorIds.removeAll()
        self.apy = StakingDefaultApy
        self.isSetup = false
        
        clearCache()
    }
}

extension StakingManager {
    struct StakingCache: Codable {
        var nodeInfos: [StakingNode] = []
        var apy: Double = StakingDefaultApy
        var isSetup: Bool = false
    }
    
    private func createFolderIfNeeded() {
        do {
            if !FileManager.default.fileExists(atPath: rootFolder.relativePath) {
                try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true)
            }
        } catch {
            debugPrint("StakingManager -> createFolderIfNeeded error: \(error)")
        }
    }
    
    private func saveCache() {
        let cacheObj = StakingCache(nodeInfos: nodeInfos, apy: apy, isSetup: isSetup)
        
        do {
            let data = try JSONEncoder().encode(cacheObj)
            try data.write(to: cacheFile)
        } catch {
            debugPrint("StakingManager -> saveCache: error: \(error)")
            clearCache()
        }
    }
    
    private func loadCache() {
        if !FileManager.default.fileExists(atPath: cacheFile.relativePath) {
            return
        }
        
        do {
            let data = try Data(contentsOf: cacheFile)
            let cacheObj = try JSONDecoder().decode(StakingCache.self, from: data)
            self.nodeInfos = cacheObj.nodeInfos
            self.apy = cacheObj.apy
            self.isSetup = cacheObj.isSetup
        } catch {
            debugPrint("StakingManager -> loadCache error: \(error)")
            clearCache()
            return
        }
    }
    
    private func clearCache() {
        if FileManager.default.fileExists(atPath: cacheFile.relativePath) {
            do {
                try FileManager.default.removeItem(at: cacheFile)
            } catch {
                debugPrint("StakingManager -> clearCache: error: \(error)")
            }
        }
    }
}
