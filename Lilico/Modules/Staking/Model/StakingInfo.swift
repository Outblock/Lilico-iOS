//
//  StakingInfo.swift
//  Lilico
//
//  Created by Selina on 1/12/2022.
//

import Foundation

struct StakingNode: Codable {
    let delegatorId: Int
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

struct StakingInfo: Codable {
    var nodes: [StakingNode] = []
}

struct NewStakingInfoInner: Codable {
    let id: UInt32
    let nodeID: String
    let tokensCommitted: Decimal
    let tokensStaked: Decimal
    let tokensUnstaking: Decimal
    let tokensRewarded: Decimal
    let tokensUnstaked: Decimal
    let tokensRequestedToUnstake: Decimal
}

struct StakingInfoInner: Codable {
    let type: String?
    let value: [StakingInfoInner.Value?]?
}

extension StakingInfoInner {
    struct Value: Codable {
        let type: String?
        let value: StakingInfoInner.Value.Value1?
        
        func getByName(_ name: String) -> String? {
            guard let fields = value?.fields else {
                return nil
            }
            
            let compactFields = fields.compactMap({ $0 })
            let first = compactFields.first { field in
                field.name == name
            }
            
            guard let first = first else {
                return nil
            }
            
            return first.value?.value
        }
    }
}

extension StakingInfoInner.Value {
    struct Value1: Codable {
        let fields: [StakingInfoInner.Value.Value1.Field?]?
        let id: String?
    }
}

extension StakingInfoInner.Value.Value1 {
    struct Field: Codable {
        let name: String?
        let value: StakingInfoInner.Value.Value1.Field.Value2?
        
    }
}

extension StakingInfoInner.Value.Value1.Field {
    struct Value2: Codable {
        let type: String?
        let value: String?
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
