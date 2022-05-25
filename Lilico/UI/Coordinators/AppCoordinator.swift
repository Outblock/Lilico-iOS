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

    @Root var home = makeHome

    init() {
        stack = NavigationStack(initial: \MainCoordinator.home)
    }
}

extension MainCoordinator {
    func makeHome() -> NavigationViewCoordinator<NewTabBarCoordinator> {
        return NavigationViewCoordinator(NewTabBarCoordinator())
    }
}
