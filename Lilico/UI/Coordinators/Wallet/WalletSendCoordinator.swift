//
//  WalletSendCoordinator.swift
//  Lilico
//
//  Created by Selina on 11/7/2022.
//

import Combine
import Stinsen
import SwiftUI

final class WalletSendCoordinator: NavigationCoordinatable {
    let stack = NavigationStack(initial: \WalletSendCoordinator.start)
    
    @Root var start = makeStart
    @Route(.push) var amount = makeSendAmount
    
    @ViewBuilder func makeStart() -> some View {
        WalletSendView()
    }
    
    @ViewBuilder func makeSendAmount(target: Contact) -> some View {
        WalletSendAmountView(target: target)
    }
}
