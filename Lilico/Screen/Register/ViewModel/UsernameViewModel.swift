//
//  UsernameViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation
import Stinsen
import SwiftUI

typealias VoidBlock = () -> Void
typealias BoolBlock = (Bool) -> Void

struct UsernameViewState {
//    var delegate: LL.TextField.Delegate

//    var isChecking: Bool = false
//    var isVaildate: Bool? = nil
    
    var status: LL.TextField.Status = .normal
}

enum UsernameViewAction {
    case next
    case onEditingChanged(String)
    case onCommit
}

class UsernameViewModel: ViewModel {
    @Published
    private(set) var state: UsernameViewState

    init() {
        state = .init()
    }

    func trigger(_ input: UsernameViewAction) {
        switch input {
        case .next:
            break
        case let .onEditingChanged(text):
            checkUsername(text)
        case .onCommit:
            break
        }
    }

    func checkUsername(_ username: String)  {
        state.status = .loading()
        Task {
            do {
                let model:CheckUserNameModel = try await Network.request(LilicoEndpoint.checkUsername(username))
                await MainActor.run {
                    self.state.status = model.unique ? .success() : .error()
                }
            } catch let error {
                await MainActor.run {
                    self.state.status = .error()
                }
                print(error)
            }
        }
    }
}
