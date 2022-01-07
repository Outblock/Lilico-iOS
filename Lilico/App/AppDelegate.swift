//
//  AppDelegate.swift
//  Lilico-lite
//
//  Created by Hao Fu on 12/12/21.
//

import Firebase
import Foundation
import GoogleSignIn
import IQKeyboardManagerSwift
import Resolver
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Resolver.registerAllServices()
//        IQKeyboardManager.shared.enable = true

        UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "arrow.backward")

        for family in UIFont.familyNames {
            print(family)

            for names in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
            }
        }

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
