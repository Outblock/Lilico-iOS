//
//  AppDelegate.swift
//  Lilico-lite
//
//  Created by Hao Fu on 12/12/21.
//

import Foundation
import UIKit
import Firebase
//import Bagel

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        #if DEBUG
//        Bagel.start()
        #endif
        return true
    }
}
