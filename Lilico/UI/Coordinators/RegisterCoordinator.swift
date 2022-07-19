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

    var name: String?

    @ViewBuilder func makeTerms() -> some View {
        TermsAndPolicy()
    }

    @ViewBuilder func makeUsername() -> some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
    }

    @ViewBuilder func makeTYNK() -> some View {
        if let username = name {
            TYNKView(viewModel: TYNKViewModel(username: username).toAnyViewModel())
        } else {
            Text("Error: Empty username")
        }
    }
}
