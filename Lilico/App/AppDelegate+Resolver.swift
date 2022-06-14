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
        register { UserManager.shared }
        register { WalletManager.shared }
        register { BackupManager.shared }
    }
}
