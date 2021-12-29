//
//  OnBoradingCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import SwiftUI
import Stinsen

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
