//
//  OnboardingViewModel.swift
//  Lilico-lite
//
//  Created by Hao Fu on 28/11/21.
//

import Foundation
import Stinsen
import SwiftUI

class OnboardingViewModel: ViewModel {
    @RouterObject
    var router: NavigationRouter<OnBoradingCoordinator>!

    @Published
    private(set) var state: OnboardingState

    public init() {
        let intros: [Intro] = [
            Intro(image: "Onboarding_1",
                  title: "Secure your funds",
                  description: "But they are not the inconvenience that our pleasure.",
                  color: Color.LL.orange,
                  rectColor: Color(hex: "#FFCF4E")),
            Intro(image: "Onboarding_2",
                  title: "Manage your crypto asset",
                  description: "There is no provision to smooth the consequences are.",
                  color: Color.LL.orange,
                  rectColor: Color(hex: "#FF81B4")),
            Intro(image: "Onboarding_3",
                  title: "A new NFT experience",
                  description: "Node is a platform that aims to build a new creative economy.",
                  color: Color.LL.orange,
                  rectColor: Color(hex: "#00ACFB")),
        ]
        state = OnboardingState(intros: intros)
    }

    func trigger(_ input: OnboardingAction) {
        switch input {
        case .finish, .skip:
            router.coordinator.route(to: \.setup)
//            router.trigger(to: .home, with: .push)
//            trigger(to: .home, with: .push)
//            appRouter.trigger(to: .home, with: .push)
//            break;

//            router?.navigate(to: Routes.home)
//            router?.navigate(to: Routes.home, using: SheetPresenter(), source: .none)
//        case let .bind(router):
//            self.router = router
//            break;
        }
    }
}
