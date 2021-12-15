//
//  Lilico_liteApp.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI
import sRouting

@main
struct Lilico_App: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RootView(rootRouter: .init()) {
                          NavigationView {
                              AppRoute.login.screen
                          }
                          .navigationBarHidden(true)
                          .navigationTitle("")
                          .hideNavigationBar()
                          .navigationViewStyle(.stack)
                      }
        }
    }
}


enum AppRoute: Route {
    case login
    case home

    var screen: some View {
        switch self {
        case .login: OnboardingView(viewModel: OnboardingViewModel().toAnyViewModel())
            case .home: HomeView()
        }
    }
}
