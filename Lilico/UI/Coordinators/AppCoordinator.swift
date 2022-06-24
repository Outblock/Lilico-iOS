//
//  Router.swift
//  Lilico-lite
//
//  Created by Hao Fu on 5/12/21.
//

import Foundation
import SwiftUI
import SwiftUIX
import Stinsen

final class MainCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \MainCoordinator.home)

    @Root var home = makeHome

}

extension MainCoordinator {
    func makeHome() -> NavigationViewCoordinator<TabBarCoordinator> {
        return NavigationViewCoordinator(TabBarCoordinator())
    }
}
