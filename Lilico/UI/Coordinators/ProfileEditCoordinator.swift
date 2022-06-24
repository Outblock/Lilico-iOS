//
//  ProfileEditCoordinator.swift
//  Lilico
//
//  Created by Selina on 14/6/2022.
//

import Stinsen
import SwiftUI

final class ProfileEditCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \ProfileEditCoordinator.start)

    @Root var start = makeProfileEditView
    @Route(.push) var nameEdit = makeEditNameView
    @Route(.push) var avatarEdit = makeEditAvatarView

//    var addressBookVM: AddressBookView.AddressBookViewModel?
}

extension ProfileEditCoordinator {
    @ViewBuilder func makeProfileEditView() -> some View {
        ProfileEditView()
    }

    func makeEditNameView() -> some View {
        ProfileEditNameView()
    }

    func makeEditAvatarView(items: [EditAvatarView.AvatarItemModel]) -> some View {
        EditAvatarView(items: items)
    }
}
