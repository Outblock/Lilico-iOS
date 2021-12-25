//
//  EmptyViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import Foundation
import SwiftUI
import SwiftUIX

struct EmptyWalletState {
    var dataSource: [CardDataSource]
}

enum EmptyWalletAction {
    case signUp
    case signIn
}

struct CardDataSource: Identifiable {
    var id = UUID().uuidString
    var title: String
    let bgGradient: [Color]
    let bgImage: Image
    let buttonText: String
    let icon: Image
    let iconColor: Color
    let action: EmptyWalletAction
}
