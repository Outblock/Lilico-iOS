//
//  WalletSetupViewModel.swift
//  Lilico-lite
//
//  Created by Hao Fu on 28/11/21.
//

import Foundation

struct WalletSetupState {
//    let dataSource:
}

enum WalletSetupAction {
    case createWallet
    case importWallet
    case importAddress
}

class WalletSetupViewModel: ViewModel {
    @Published
    private(set) var state: WalletSetupState

    init() {
        state = WalletSetupState()
    }

    func trigger(_: WalletSetupAction) {}
}
