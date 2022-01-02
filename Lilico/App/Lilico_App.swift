//
//  Lilico_liteApp.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import Resolver
import SwiftUI

@main
struct Lilico_App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var umanager: UserManager = Resolver.resolve()

    var body: some Scene {
        WindowGroup {
            MainCoordinator()
                .view()
                .task {
                    umanager.listenAuthenticationState()
                    await umanager.login()
                }
        }
    }
}
