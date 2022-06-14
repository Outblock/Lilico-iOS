//
//  ProfileEditCoordinator.swift
//  Lilico
//
//  Created by Selina on 14/6/2022.
//

import SwiftUI

final class ProfileEditCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<ProfileEditCoordinator>
    
    @Root var start = makeProfileEditView
    @Route(.push) var nameEdit = makeEditNameView
//    @Route(.push) var edit = makeEditView
    
//    var addressBookVM: AddressBookView.AddressBookViewModel?
    
    init() {
        stack = NavigationStack(initial: \ProfileEditCoordinator.start)
    }
}

extension ProfileEditCoordinator {
    @ViewBuilder func makeProfileEditView() -> some View {
        ProfileEditView()
    }
    
    func makeEditNameView() -> some View {
        ProfileEditNameView()
    }
}
