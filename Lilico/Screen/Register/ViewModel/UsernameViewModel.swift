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

class UsernameViewModel: ViewModel {
    @Published
    private(set) var state: UsernameView.ViewState

    var lastUpdateTime: Date = .init()
    var task: DispatchWorkItem?
    var currentText: String = ""

    var router: RegisterCoordinator.Router? = RouterStore.shared.retrieve()

    init() {
        state = .init()
    }

    func trigger(_ input: UsernameView.Action) {
        switch input {
        case .next:
            UIApplication.shared.endEditing()
            router?.coordinator.name = currentText
            router?.route(to: \.TYNK)
        case let .onEditingChanged(text):
            currentText = text
            if localCheckUserName(text) {
                state.status = .loading()
                task?.cancel()
                task = DispatchWorkItem {
                    self.checkUsername(text)
                }
                if let work = task {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: work)
                }
            }
        }
    }

    func localCheckUserName(_ username: String) -> Bool {
        if username.count < 3 {
            state.status = .error("Too short")
            return false
        }

        if username.count > 15 {
            state.status = .error("Too long ")
            return false
        }

        guard let _ = username.range(of: "^[A-Za-z0-9_]{3,15}$", options: .regularExpression) else {
            state.status = .error("Your username can only contain letters, numbers and '_'")
            return false
        }

        return true
    }

    func checkUsername(_ username: String) {
        Task {
            do {
                let model: CheckUserNameModel = try await Network.request(LilicoEndpoint.checkUsername(username.lowercased()))
                await MainActor.run {
                    if model.username == currentText {
                        self.state.status = model.unique ? .success() : .error("It's taken")
                    }
                }
            } catch {
                await MainActor.run {
                    self.state.status = .error()
                }
                print(error)
            }
        }
    }
}
