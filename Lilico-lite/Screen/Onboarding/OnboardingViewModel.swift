//
//  OnboardingViewModel.swift
//  Lilico-lite
//
//  Created by Hao Fu on 28/11/21.
//

import Foundation
import SwiftUI

struct Intro: Identifiable {
    var id = UUID().uuidString
    var image: String
    var title: String
    var description: String
    var color: Color
    var rectColor: Color
}

struct OnboardingState {
    var intros: [Intro]
}

enum OnboardingAction {
    case finish
    case skip
}

class OnboardingViewModel: ViewModel {
    @Published
    private(set) var state: OnboardingState
    
    init() {
        let intros: [Intro] = [
            Intro(image: "Onboarding_1",
                  title: "Secure your funds",
                  description: "But they are not the inconvenience that our pleasure.",
                  color: Color.LL.primary,
                  rectColor: Color(hex: "#FFCF4E")),
            Intro(image: "Onboarding_2",
                  title: "Manage your crypto asset",
                  description: "There is no provision to smooth the consequences are.",
                  color: Color.LL.primary,
                  rectColor: Color(hex: "#FF81B4")),
            Intro(image: "Onboarding_3",
                  title: "A new NFT experience",
                  description: "Node is a platform that aims to build a new creative economy.",
                  color: Color.LL.primary,
                  rectColor: Color(hex: "#00ACFB")),
        ]
        
        state = OnboardingState(intros: intros)
    }
    
    func trigger(_ input: OnboardingAction) {
        switch input {
        case .finish, .skip:
            break;
        }
    }

}
