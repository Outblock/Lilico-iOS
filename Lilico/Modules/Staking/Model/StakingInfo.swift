//
//  StakingInfo.swift
//  Lilico
//
//  Created by Selina on 1/12/2022.
//

import Foundation

struct StakingNode: Codable {
    let id: Int
    let nodeID: String
    let tokensCommitted: Double
    let tokensStaked: Double
    let tokensUnstaking: Double
    let tokensRewarded: Double
    let tokensUnstaked: Double
    let tokensRequestedToUnstake: Double
    
    var stakingCount: Double {
        return tokensCommitted + tokensStaked
    }
    
    var isLilico: Bool {
        return StakingProviderCache.cache.providers.first { $0.isLilico }?.id == nodeID
    }
}

// MARK: - DelegatorInner

struct StakingDelegatorInner: Codable {
    let type: String?
    let value: StakingDelegatorInner.Value1?
}

extension StakingDelegatorInner {
    struct Value1: Codable {
        let type: String?
        let value: [StakingDelegatorInner.Value1.Value2?]?
    }
}

extension StakingDelegatorInner.Value1 {
    struct Value2: Codable {
        let key: StakingDelegatorInner.Value1.Value2.Key?
        let value: StakingDelegatorInner.Value1.Value2.Value?
    }
}

extension StakingDelegatorInner.Value1.Value2 {
    struct Key: Codable {
        let type: String?
        let value: String?
    }
    
    struct Value: Codable {
        let type: String?
        let value: [StakingDelegatorInner.Value1.Value2.Value.Value3?]?
    }
}

extension StakingDelegatorInner.Value1.Value2.Value {
    struct Value3: Codable {
        let key: StakingDelegatorInner.Value1.Value2.Value.Value3.Key?
    }
}

extension StakingDelegatorInner.Value1.Value2.Value.Value3 {
    struct Key: Codable {
        let type: String?
        let value: String?
    }
}
