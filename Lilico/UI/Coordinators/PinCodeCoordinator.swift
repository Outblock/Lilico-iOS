//
//  PinCodeCoordinator.swift
//  Lilico
//
//  Created by cat on 2022/5/11.
//

import Foundation
import Stinsen
import SwiftUI
import SwiftUIX

final class PinCodeCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \PinCodeCoordinator.start)

    @Root var start = makeStart
    @Route(.push) var confirmPinCode = makeConfirmPinCode
}

extension PinCodeCoordinator {
    @ViewBuilder func makeStart() -> some View {
        CreatePinCodeView(viewModel: CreatePinCodeViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    @ViewBuilder func makeConfirmPinCode(lastPin: String) -> some View {
        ConfirmPinCodeView(viewModel: ConfirmPinCodeViewModel(pin: lastPin).toAnyViewModel())
            .hideNavigationBar()
    }
}
