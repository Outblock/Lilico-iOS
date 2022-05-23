//
//  ProfileCoordinator.swift
//  Lilico
//
//  Created by Selina on 18/5/2022.
//

import Foundation
import SwiftUI

final class ProfileCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<ProfileCoordinator>
    
    @Root var start = makeProfileView
    @Route(.push) var themeChange = makeThemeChangeView
    
    init() {
        stack = NavigationStack(initial: \ProfileCoordinator.start)
    }
}

extension ProfileCoordinator {
    @ViewBuilder func makeProfileView() -> some View {
        ProfileView()
    }
    
    @ViewBuilder func makeThemeChangeView() -> some View {
        ThemeChangeView()
    }
}
