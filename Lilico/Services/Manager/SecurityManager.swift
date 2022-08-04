//
//  SecurityManager.swift
//  Lilico
//
//  Created by Selina on 4/8/2022.
//

import SwiftUI
import KeychainAccess

extension SecurityManager {
    enum SecurityType: Int {
        case none
        case pin
        case bionic
        case both
    }
}

class SecurityManager {
    static let shared = SecurityManager()
    private let PinCodeKey = "PinCodeKey"
    
    var securityType: SecurityType {
        return LocalUserDefaults.shared.securityType
    }
    
    var currentPinCode: String {
        guard let code = try? WalletManager.shared.mainKeychain.getString(PinCodeKey) else {
            return ""
        }
        
        return code
    }
    
    func appendSecurity(type: SecurityType) {
        let currentType = securityType
        
        if currentType == .both {
            return
        }
        
        if currentType == type {
            return
        }
        
        switch currentType {
        case .none:
            LocalUserDefaults.shared.securityType = type
        default:
            LocalUserDefaults.shared.securityType = .both
        }
    }
    
    func removeSecurity(type: SecurityType) {
        if type == .none {
            return
        }
        
        let currentType = securityType
        
        if currentType == type {
            LocalUserDefaults.shared.securityType = .none
            return
        }
        
        if currentType == .both {
            if type == .pin {
                LocalUserDefaults.shared.securityType = .bionic
            } else if type == .bionic {
                LocalUserDefaults.shared.securityType = .pin
            }
        }
    }
    
    func updatePinCode(_ code: String) throws {
        try WalletManager.shared.mainKeychain.set(code, key: PinCodeKey)
    }
}
