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
import SwiftUI
import UIKit
import WalletCore

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?
    lazy var coordinator = Coordinator(window: window!)
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        appConfig()
        commonConfig()
        flowConfig()
        FirebaseConfig.start()
        
        setupUI()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Config

extension AppDelegate {
    private func setupNavigationBar() {
        let font = UIFont(name: "Inter", size: 18)?.semibold
        let largeFont = UIFont(name: "Inter", size: 24)?.bold
        let color = UIColor(named: "neutrals.text")!
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color, .font: font!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: color, .font: largeFont!]
        
//        let emptyImage = UIImage()
//        UINavigationBar.appearance().backIndicatorImage = emptyImage
//        UINavigationBar.appearance().backIndicatorTransitionMaskImage = emptyImage
    }
    
    private func appConfig() {
        _ = UserManager.shared
        _ = WalletManager.shared
        _ = BackupManager.shared
        _ = NFTListCache.cache
    }

    private func commonConfig() {
        setupNavigationBar()
        
        UITableView.appearance().sectionHeaderTopPadding = 0
        UISearchBar.appearance().tintColor = UIColor(Color.LL.Secondary.violetDiscover)
        UINavigationBar.appearance().shadowImage = UIImage()

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .orange
        
        HUD.setupProgressHUD()
    }

    private func flowConfig() {
        FlowNetwork.setup()
    }
}

// MARK: - UI

extension AppDelegate {
    private func setupUI() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .systemBackground
        
        coordinator.showVerifyView()
        
        self.window?.makeKeyAndVisible()
    }
}
