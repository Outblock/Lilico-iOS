//
//  BackupPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Foundation
import Stinsen

class BackupPasswordViewModel: ViewModel {
    @Published
    private(set) var state: BackupPasswordView.ViewState = .init()

    @RouterObject
    var router: HomeCoordinator.Router?

    init() {}

    func trigger(_ input: BackupPasswordView.Action) {
        switch input {
        case let .onPasswordChanged(password):

            break
        case let .onConfirmChanged(confirmPassword):
            break
        default:
            break
        }
    }
}
