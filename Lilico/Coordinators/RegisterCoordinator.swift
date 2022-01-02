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
    @Route(.push) var userName = makeUsername

    @ViewBuilder func makeTerms() -> some View {
        TermsAndPolicy()
            .hideNavigationBar()
    }

    @ViewBuilder func makeUsername() -> some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
            .hideNavigationBar()
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
