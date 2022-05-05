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
    
    private func fetchConfig() async throws -> RemoteConfigValue {
        try await withCheckedThrowingContinuation { continuation in
            let remoteConfig = RemoteConfig.remoteConfig()
            remoteConfig.fetchAndActivate(completionHandler: { status, error in
                if status == .error {
                    continuation.resume(throwing: error as! Never)
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

