//
//  LocalUserDefaultsManager.swift
//  Lilico
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI
import Flow

extension LocalUserDefaults {
    enum Keys: String {
        case flowNetwork
        case userInfo
        case walletHidden
    }
    
    enum FlowNetworkType: String {
        case testnet
        case mainnet
        
        func toFlowType() -> Flow.ChainID {
            switch self {
            case .testnet:
                return Flow.ChainID.testnet
            case .mainnet:
                return Flow.ChainID.mainnet
            }
        }
    }
}

class LocalUserDefaults: ObservableObject {
    static let shared = LocalUserDefaults()
    
    #if DEBUG
    @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .testnet {
        didSet {
            FlowNetwork.setup()
            WalletManager.shared.reloadWalletInfo()
        }
    }
    #else
    @AppStorage(Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .mainnet {
        didSet {
            FlowNetwork.setup()
            WalletManager.shared.reloadWalletInfo()
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
    
    @AppStorage(Keys.walletHidden.rawValue) var walletHidden: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .walletHiddenFlagUpdated, object: nil)
        }
    }
}
