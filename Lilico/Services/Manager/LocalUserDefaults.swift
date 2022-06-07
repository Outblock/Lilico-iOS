//
//  LocalUserDefaultsManager.swift
//  Lilico
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI

extension LocalUserDefaults {
    enum Keys: String {
        case flowNetwork
        case userInfo
    }
    
    enum FlowNetworkType: String {
        case testnet
        case mainnet
    }
}

class LocalUserDefaults: ObservableObject {
    static let shared = LocalUserDefaults()
    
    #if DEBUG
    @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .testnet {
        didSet {
            FlowNetwork.setup()
        }
    }
    #else
    @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .mainnet {
        didSet {
            FlowNetwork.setup()
        }
    }
    #endif
    
    var userInfo: UserInfo? {
        set {
            if let value = newValue, let data = try? LilicoAPI.jsonEncoder.encode(value) {
                UserDefaults.standard.set(data, forKey: Keys.userInfo.rawValue)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.userInfo.rawValue)
            }
        }
        get {
            if let data = UserDefaults.standard.data(forKey: Keys.userInfo.rawValue), let info = try? LilicoAPI.jsonDecoder.decode(UserInfo.self, from: data) {
                return info
            } else {
                return nil
            }
        }
    }
}
