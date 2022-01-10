//
//  RegisterCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Stinsen
import SwiftUI

final class RegisterCoordinator: NavigationCoordinatable {
    var stack = NavigationStack(initial: \RegisterCoordinator.termScreen)

    @Root var termScreen = makeTerms
    @Route(.push) var username = makeUsername
    @Route(.push) var TYNK = makeTYNK
    @Route(.push) var recoveryPhrase = makeRecoveryPhrase

    var name: String?

    @ViewBuilder func makeTerms() -> some View {
        TermsAndPolicy()
            .hideNavigationBar()
    }

    @ViewBuilder func makeUsername() -> some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
            .hideNavigationBar()
    }

    @ViewBuilder func makeTYNK() -> some View {
        if let username = name {
            TYNKView(viewModel: TYNKViewModel(username: username).toAnyViewModel())
                .hideNavigationBar()
        } else {
            Text("Error: Empty username")
        }
    }

    func makeRecoveryPhrase() -> BackupCoordinator {
        BackupCoordinator()
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
