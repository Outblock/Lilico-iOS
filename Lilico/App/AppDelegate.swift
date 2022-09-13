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

#if DEBUG
import Atlantis
#endif

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
        
        #if DEBUG
            Atlantis.start()
        #endif

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        
        var parameters: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        
        if let filtered = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
            .filter({ $0.name == "uri" && $0.value?.starts(with: "wc") ?? false }),
           let item = filtered.first, let uri = item.value {
            WalletConnectManager.shared.onClientConnected = {
                WalletConnectManager.shared.connect(link: uri)
            }
            
            
        }
        
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let url = userActivity.webpageURL {
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            if let filtered = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
                .filter({ $0.name == "uri" && $0.value?.starts(with: "wc") ?? false }),
                let item = filtered.first, let uri = item.value {
                WalletConnectManager.shared.onClientConnected = {
                    WalletConnectManager.shared.connect(link: uri)
                }
               }
        }
        
        return true
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
        _ = SecurityManager.shared
        _ = WalletConnectManager.shared
        _ = RemoteConfigManager.shared
    }

    private func commonConfig() {
        setupNavigationBar()
        
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().sectionHeaderTopPadding = 0
        UISearchBar.appearance().tintColor = UIColor.LL.Secondary.violetDiscover
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
        self.window?.backgroundColor = UIColor.LL.Primary.salmonPrimary
        
        coordinator.showRootView()
        coordinator.rootNavi?.view.alpha = 0
        
        self.window?.makeKeyAndVisible()
        
        SecurityManager.shared.lockAppIfNeeded()
        
        UIView.animate(withDuration: 0.2, delay: 0.1) {
            self.coordinator.rootNavi?.view.alpha = 1
        }
    }
}
