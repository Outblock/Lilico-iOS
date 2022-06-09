//
//  AppDelegate+Resolver.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        let _ = UserManager.shared
        let _ = WalletManager.shared
        let _ = BackupManager.shared
        
        register { UserManager.shared }
        register { WalletManager.shared }
        register { BackupManager.shared }
    }
}
