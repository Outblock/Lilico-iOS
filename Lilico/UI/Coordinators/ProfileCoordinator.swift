//
//  ProfileCoordinator.swift
//  Lilico
//
//  Created by Selina on 18/5/2022.
//

import Foundation
import SwiftUI

final class ProfileCoordinator: NavigationCoordinatable, AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .profile
    }
    
    static func iconName() -> String {
        return "house.fill"
    }
    
    static func color() -> Color {
        return .purple
    }
    
    let stack: NavigationStack<ProfileCoordinator>
    
    @Root var start = makeProfileView
    @Route(.push) var themeChange = makeThemeChangeView
    @Route(.push) var addressBook = makeAddressBook
    
    init() {
        stack = NavigationStack(initial: \ProfileCoordinator.start)
    }
}

extension ProfileCoordinator {
    @ViewBuilder func makeProfileView() -> some View {
        ProfileView().hideNavigationBar()
    }
    
    @ViewBuilder func makeThemeChangeView() -> some View {
        ThemeChangeView()
    }
    
    func makeAddressBook() -> AddressBookCoordinator {
        return AddressBookCoordinator()
    }
}