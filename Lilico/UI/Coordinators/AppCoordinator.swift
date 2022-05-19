//
//  Router.swift
//  Lilico-lite
//
//  Created by Hao Fu on 5/12/21.
//

import Foundation
import SwiftUI
import SwiftUIX

final class MainCoordinator: NavigationCoordinatable {
    var stack: NavigationStack<MainCoordinator>

    @Root var onboarding = makeOnboarding
    @Root var home = makeHome

    init() {
        stack = NavigationStack(initial: \MainCoordinator.home)
    }
}

extension MainCoordinator {
    func makeOnboarding() -> NavigationViewCoordinator<OnBoradingCoordinator> {
        return NavigationViewCoordinator(OnBoradingCoordinator())
    }

    func makeHome() -> NavigationViewCoordinator<NewTabBarCoordinator> {
        return NavigationViewCoordinator(NewTabBarCoordinator())
    }
}
