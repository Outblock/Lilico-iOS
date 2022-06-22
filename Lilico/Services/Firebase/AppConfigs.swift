//
//  FlowCoins.swift
//  Lilico
//
//  Created by cat on 2022/4/30.
//

import Foundation
import FirebaseRemoteConfig
import Haneke

enum AppConfig: String {
    case flowCoins = "flow_coins"
    case nftCollections = "nft_collections"
    
}

enum AppConfigError: Error {
    case fetch
    case decode
}

extension AppConfig {
    
    func fetch() async throws -> Data {
        do {
            let value = try await fetchConfig()
            return value.dataValue
            
        }catch  {
            throw error
        }
    }
    
    func fetchList<T: Codable>() async throws -> [T] {
        let data = try? await fetch()
        guard let data = data else {
            throw AppConfigError.fetch
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let collections = try decoder.decode([T].self, from: data)
            return collections
            
        } catch  {
            throw AppConfigError.decode
        }
    }
    
    
    private func fetchConfig() async throws -> RemoteConfigValue {
        try await withCheckedThrowingContinuation { continuation in
            let remoteConfig = RemoteConfig.remoteConfig()
            remoteConfig.fetchAndActivate(completionHandler: { status, error in
                if status == .error {
                    continuation.resume(throwing: AppConfigError.fetch)
                    print("Config not fetched")
                    print("Error: \(error?.localizedDescription ?? "No error available.")")
                } else {
                    print("Config fetched!")
                    let configValues: RemoteConfigValue = remoteConfig.configValue(forKey: self.rawValue)
                    continuation.resume(returning: configValues)
                }
            })
        }
        
    }
}

