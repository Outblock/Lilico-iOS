//
//  ProfileViewModel.swift
//  Lilico
//
//  Created by Selina on 23/5/2022.
//

import Combine
import Foundation
import SwiftUI

extension ProfileView {
    struct ProfileState {
        var isLogin: Bool = false
        var currency: String = "USD"
        var colorScheme: ColorScheme?
    }

    enum ProfileInput {}

    class ProfileViewModel: ViewModel {
        @Published var state = ProfileState()

        private var cancellable: AnyCancellable?

        init() {
            print("ProfileViewModel init")
            state.colorScheme = ThemeManager.shared.style

            cancellable = ThemeManager.shared.$style.sink(receiveValue: { [weak self] newScheme in
                self?.state.colorScheme = newScheme
            })
        }

        func trigger(_: ProfileInput) {}
    }
}
