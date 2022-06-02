//
//  AddressBookCoordinator.swift
//  Lilico
//
//  Created by Selina on 24/5/2022.
//

import Foundation
import SwiftUI

final class AddressBookCoordinator: NavigationCoordinatable {
    let stack: NavigationStack<AddressBookCoordinator>
    
    @Root var start = makeAddressBookView
    @Route(.push) var add = makeAddView
    
    var addressBookVM: AddressBookView.AddressBookViewModel?
    
    init() {
        stack = NavigationStack(initial: \AddressBookCoordinator.start)
    }
}

extension AddressBookCoordinator {
    @ViewBuilder func makeAddressBookView() -> some View {
        AddressBookView()
    }
    
    @ViewBuilder func makeAddView() -> some View {
        AddAddressView()
    }
}
