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
//                .onAppear {
//                    overrideNavigationAppearance()
//                }
//                .hideNavigationBar()
                .task {
                    umanager.listenAuthenticationState()
                    await umanager.login()
                }
        }
    }
}

extension Lilico_App {
    func overrideNavigationAppearance() {
        // 设置样式 iOS 15生效
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
//        coloredAppearance.backgroundColor = UIColor.purple
        coloredAppearance.shadowColor = .clear
        let titleAttributed: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.clear,
        ]

        coloredAppearance.titleTextAttributes = titleAttributed

        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.backButtonAppearance = backButtonAppearance

        let backImage = UIImage(systemName: "square.and.pencil")
        coloredAppearance.setBackIndicatorImage(backImage,
                                                transitionMaskImage: backImage)
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
}
