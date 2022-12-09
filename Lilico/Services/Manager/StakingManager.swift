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

class StakingManager: ObservableObject {
    static let shared = StakingManager()
    
    private lazy var rootFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("staking_cache")
    private lazy var cacheFile = rootFolder.appendingPathComponent("cache_file")
    
    @Published var info: StakingInfo = StakingInfo()
    @Published var delegatorIds: [String: Int] = [:]
    @Published var apy: Double = StakingDefaultApy
    @Published var apyYear: Double = StakingDefaultApy
    @Published var isSetup: Bool = false
    
    private var cancelSet = Set<AnyCancellable>()
    
    var stakingCount: Double {
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
                
                if let apyYear = try await FlowNetwork.getStakingApyByYear() {
                    DispatchQueue.main.async {
                        self.apyYear = apyYear
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
        self.info = StakingInfo()
        self.delegatorIds.removeAll()
        self.apy = StakingDefaultApy
        self.apyYear = StakingDefaultApy
        self.isSetup = false
        
        clearCache()
    }
}

extension StakingManager {
    struct StakingCache: Codable {
        var info: StakingInfo?
        var apy: Double = StakingDefaultApy
        var apyYear: Double = StakingDefaultApy
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
        let cacheObj = StakingCache(info: info, apy: apy, apyYear: apyYear, isSetup: isSetup)
        
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
            if let info = cacheObj.info {
                self.info = info
            }
            self.apy = cacheObj.apy
            self.apyYear = cacheObj.apyYear
            self.isSetup = cacheObj.isSetup
        } catch {
            debugPrint("StakingManager -> loadCache error: \(error)")
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
