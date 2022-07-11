//
//  WalletReceiveCoordinator.swift
//  Lilico
//
//  Created by Selina on 11/7/2022.
//

import Combine
import Stinsen
import SwiftUI

final class WalletReceiveCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \WalletReceiveCoordinator.start)
    
    @Root var start = makeStart
    
    @ViewBuilder func makeStart() -> some View {
        WalletReceiveView()
    }
}
