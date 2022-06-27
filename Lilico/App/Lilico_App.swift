//
//  Lilico_liteApp.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import Resolver
import Stinsen
import SwiftUI

@main
struct Lilico_App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainCoordinator().view()
        }
    }

    init() {
        setupNavigationBar()
    }
}

extension Lilico_App {
    func setupNavigationBar() {
        let font = UIFont(name: "Inter", size: 18)?.semibold
        let largeFont = UIFont(name: "Inter", size: 24)?.bold
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(Color.LL.Neutrals.text), .font: font!]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(Color.LL.Neutrals.text), .font: largeFont!]
    }
}
