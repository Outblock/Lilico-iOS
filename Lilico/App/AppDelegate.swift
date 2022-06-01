//
//  AppDelegate.swift
//  Lilico-lite
//
//  Created by Hao Fu on 12/12/21.
//

import Firebase
import Foundation
import GoogleSignIn
import Resolver
import UIKit
import WalletCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Resolver.registerAllServices()
        commonConfig()
        flowConfig()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Config

extension AppDelegate {
    private func commonConfig() {
        UITableView.appearance().sectionHeaderTopPadding = 0
        UISearchBar.appearance().tintColor = UIColor(Color.LL.Secondary.violetDiscover)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .orange
    }
    
    private func flowConfig() {
        FlowNetwork.setup()
    }
}
