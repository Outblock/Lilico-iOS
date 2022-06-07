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
    }
    
    enum FlowNetworkType: String {
        case testnet
        case mainnet
    }
}

class LocalUserDefaults: ObservableObject {
    static let shared = LocalUserDefaults()
    
    #if DEBUG
    @AppStorage(LocalUserDefaults.Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .testnet {
        didSet {
            FlowNetwork.setup()
        }
    }
    #else
    @AppStorage(LocalUserDefaults.Keys.flowNetwork.rawValue) var flowNetwork: FlowNetworkType = .mainnet {
        didSet {
            FlowNetwork.setup()
        }
    }
    #endif
}
