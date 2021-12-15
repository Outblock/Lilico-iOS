//
//  OnboardingModel.swift
//  Lilico-lite
//
//  Created by Hao Fu on 5/12/21.
//

import Foundation
import SwiftUI
import sRouting

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
    case bind(Router<AppRoute>)
}
