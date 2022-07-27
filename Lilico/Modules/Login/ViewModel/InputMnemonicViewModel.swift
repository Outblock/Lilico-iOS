//
//  InputMnemonicViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 8/1/22.
//

import Foundation
import WalletCore


class InputMnemonicViewModel: ViewModel {
    @Published var state: InputMnemonicView.ViewState = .init()

    func trigger(_ input: InputMnemonicView.Action) {
        switch input {
        case let .onEditingChanged(text):
            let original = text.condenseWhitespace()
            let words = original.split(separator: " ")
            var hasError = false
            for word in words {
                if Mnemonic.search(prefix: String(word)).count == 0 {
                    hasError = true
                    break
                }
            }

            DispatchQueue.main.async {
                self.state.hasError = hasError

                let valid = Mnemonic.isValid(mnemonic: original)

                if text.last == " " || valid {
                    self.state.suggestions = []
                } else {
                    self.state.suggestions = Mnemonic.search(prefix: String(words.last ?? ""))
                }

                self.state.nextEnable = valid
            }
        case .next:
            restoreLogin()
        }
    }

    private func getRawMnemonic() -> String {
        return state.text.condenseWhitespace()
    }

    private func restoreLogin() {
        HUD.loading()
        
        let mnemonic = getRawMnemonic()
        Task {
            do {
                try await UserManager.shared.restoreLogin(withMnemonic: mnemonic)
                
                HUD.dismissLoading()
                HUD.success(title: "login_success".localized)
                DispatchQueue.main.async {
                    Router.popToRoot()
                }
            } catch {
                HUD.dismissLoading()
                
                if let le = error as? LLError, le == .accountNotFound {
                    HUD.error(title: "account_not_found".localized)
                    return
                }
                
                HUD.error(title: "login_failed".localized)
            }
        }
    }
}
