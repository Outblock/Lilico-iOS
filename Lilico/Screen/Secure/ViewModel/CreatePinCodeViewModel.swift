//
//  CreatePinCodeViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation

class CreatePinCodeViewModel: ViewModel {
    @Published
    private(set) var state: CreatePinCodeView.ViewState = .init()

    @RouterObject
    var router: SecureCoordinator.Router?

    @RouterObject
    var homeRouter: HomeCoordinator.Router?

    func trigger(_ input: CreatePinCodeView.Action) {
        switch input {
        case let .input(pin):
            if pin.count == 6 {
                router?.route(to: \.confirmPinCode, pin)
            }
        }
    }
}
