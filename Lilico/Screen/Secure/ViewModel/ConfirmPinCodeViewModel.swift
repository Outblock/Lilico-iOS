//
//  ConfirmPinCodeViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation
import Stinsen

class ConfirmPinCodeViewModel: ViewModel {
    @Published
    private(set) var state: ConfirmPinCodeView.ViewState

    @RouterObject
    var router: SecureCoordinator.Router?
    
    @RouterObject
    var homeRouter: HomeCoordinator.Router?

    init(pin: String) {
        state = .init(lastPin: pin)
    }

    func trigger(_ input: ConfirmPinCodeView.Action) {
        switch input {
        case let .match(confirmPIN):
            if state.lastPin == confirmPIN {
                homeRouter?.popToRoot()
            } else {
                DispatchQueue.main.async {
                    self.state.mismatch = true
                }
            }
        }
    }
}
