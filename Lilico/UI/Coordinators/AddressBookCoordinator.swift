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
    
    init() {
        stack = NavigationStack(initial: \AddressBookCoordinator.start)
    }
}

extension AddressBookCoordinator {
    @ViewBuilder func makeAddressBookView() -> some View {
        AddressBookView()
    }
}
