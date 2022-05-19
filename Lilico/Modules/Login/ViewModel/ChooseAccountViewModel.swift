//
//  ChooseAccountViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 9/1/22.
//

import Foundation

class ChooseAccountViewModel: ViewModel {
    @Published
    var text: String = ""

    @Published
    private(set) var state: ChooseAccountView.ViewState

    @RouterObject
    var router: LoginCoordinator.Router?

    init(accountList: [BackupManager.AccountData]) {
        state = .init(dataSource: accountList)
    }

    func trigger(_ input: ChooseAccountView.Action) {
        switch input {
        case let .selectAccount(index):
            router?.route(to: \.enterPassword, state.dataSource[index])
        }
    }
}
