//
//  ProfileCoordinator.swift
//  Lilico
//
//  Created by Selina on 18/5/2022.
//

import Foundation
import Stinsen
import SwiftUI

final class ProfileCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \ProfileCoordinator.start)

    @Root var start = makeProfileView
    @Route(.push) var edit = makeEdit
}

extension ProfileCoordinator {
    @ViewBuilder func makeProfileView() -> some View {
        ProfileView().hideNavigationBar()
    }

    func makeEdit() -> ProfileEditCoordinator {
        return ProfileEditCoordinator()
    }
}
