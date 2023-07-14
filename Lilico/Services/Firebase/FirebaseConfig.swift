//
//  FlowCoins.swift
//  Lilico
//
//  Created by cat on 2022/4/30.
//

import FirebaseRemoteConfig
import Foundation
import Haneke

enum FirebaseConfigError: Error {
    case fetch
    case decode
}

enum FirebaseConfig: String {
    case all
    case flowCoins = "flow_coins"
    case config = "free_gas_config"
    case dapp
    case contractAddress = "contract_address"

    static func start() {
        Task {
            do {
                _ = try await FirebaseConfig.all.fetchConfig()
                onConfigLoadFinish()
            } catch {
                debugPrint(error)
            }
        }
    }

    static func onConfigLoadFinish() {
        Task {
            await NFTCollectionConfig.share.reload()
        }
    }
}

extension FirebaseConfig {
    func fetch<T: Codable>(decoder:JSONDecoder = LilicoAPI.jsonDecoder ) throws -> T {
        let remoteConfig = RemoteConfig.remoteConfig()
        let json = remoteConfig.configValue(forKey: rawValue)
        do {
            let collections = try decoder.decode(T.self, from: json.dataValue)
            return collections
        } catch {
            debugPrint(error)
            throw FirebaseConfigError.decode
        }
    }
    
    func fetchLocal<T: Codable>() throws -> T {
        let remoteConfig = RemoteConfig.remoteConfig()
        guard let json = remoteConfig.defaultValue(forKey: rawValue) else {
            throw FirebaseConfigError.decode
        }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let collections = try decoder.decode(T.self, from: json.dataValue)
            return collections
        } catch {
            print(error)
            throw FirebaseConfigError.decode
        }
    }

    private func fetchConfig() async throws -> RemoteConfigValue {
        try await withCheckedThrowingContinuation { continuation in
            let remoteConfig = RemoteConfig.remoteConfig()
            let setting = RemoteConfigSettings()
            setting.minimumFetchInterval = 3600
            
            #if DEBUG
            setting.minimumFetchInterval = 0
            #endif
            
            remoteConfig.configSettings = setting
            remoteConfig.setDefaults(fromPlist: "remote_config_defaults")
            remoteConfig.fetchAndActivate(completionHandler: { status, error in
                if status == .error {
                    continuation.resume(throwing: FirebaseConfigError.fetch)
                    print("Firbase fetch Error: \(error?.localizedDescription ?? "No error available.")")
                } else {
                    print("Config fetched!")
                    let configValues: RemoteConfigValue = remoteConfig.configValue(forKey: self.rawValue)
                    continuation.resume(returning: configValues)
                }
            })
        }
    }
}
