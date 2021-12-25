//
//  Router.swift
//  Lilico-lite
//
//  Created by Hao Fu on 5/12/21.
//

import Foundation
import SwiftUI
import Stinsen
import SwiftUIX

final class MainCoordinator: NavigationCoordinatable {
    var stack: NavigationStack<MainCoordinator>

    @Root var onboarding = makeOnboarding
//    @Root var home = makeHome
    
    init() {
        stack = NavigationStack(initial: \MainCoordinator.onboarding)
    }
}

extension MainCoordinator {
    func makeOnboarding() -> NavigationViewCoordinator<OnBoradingCoordinator> {
        return NavigationViewCoordinator(OnBoradingCoordinator())
    }
    
//    func makeHome() -> HomeCoordinator {
//        return HomeCoordinator()
//    }
}
//
//final class HomeCoordinator: TabCoordinatable {
//    var child = TabChild(startingItems: [
//
//    ])
//
//    func test() {
//
//    }
//}

final class OnBoradingCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \OnBoradingCoordinator.start)
    
//    let stack = NavigationStack(initial: \UnauthenticatedCoordinator.start)
//    let unauthenticatedServices = UnauthenticatedServices()
//
    @Root var start = makeOnBorading
    @Route(.push) var setup = makeSetup
//    @Route(.push) var registration = makeRegistration
    
    @ViewBuilder func makeOnBorading() -> some View {
        OnboardingView(viewModel: OnboardingViewModel().toAnyViewModel())
    }
    
    @ViewBuilder func makeSetup() -> some View {
        WalletSetupView()
    }
}
