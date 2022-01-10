//
//  SecureCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation
import Stinsen
import SwiftUI

final class SecureCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \SecureCoordinator.requestScreen)
    
    @Root var requestScreen = makeRequestSecure
    @Route(.push) var pinCode = makePinCode
    @Route(.push) var confirmPinCode = makeConfirmPinCode
    
    @ViewBuilder func makeRequestSecure() -> some View {
        RequestSecureView(viewModel: RequestSecureViewModel().toAnyViewModel())
            .hideNavigationBar()
    }
    
    @ViewBuilder func makePinCode() -> some View {
        CreatePinCodeView(viewModel: CreatePinCodeViewModel().toAnyViewModel())
            .hideNavigationBar()
    }
    
    @ViewBuilder func makeConfirmPinCode(lastPin: String) -> some View {
        ConfirmPinCodeView(viewModel: ConfirmPinCodeViewModel(pin: lastPin).toAnyViewModel())
            .hideNavigationBar()
    }

}
