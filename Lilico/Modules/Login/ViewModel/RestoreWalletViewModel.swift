//
//  RestoreWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 1/1/22.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore
import Stinsen

class RestoreWalletViewModel {
    @RouterObject var router: LoginCoordinator.Router?
}

// MARK: - Action

extension RestoreWalletViewModel {
    func restoreWithManualAction() {
        router?.route(to: \.inputMnemonic)
    }
}
