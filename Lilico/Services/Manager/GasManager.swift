//
//  GasManager.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit

// TODO: Implement Gas Free Feature
class GasManager {
    static let shared = GasManager()
    
    var payer: String {
        return WalletManager.shared.getPrimaryWalletAddress() ?? ""
    }
}
