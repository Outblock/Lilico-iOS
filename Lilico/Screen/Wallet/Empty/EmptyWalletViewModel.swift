//
//  EmptyWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import Foundation
import SwiftUI
import SwiftUIX

class EmptyWalletViewModel: ViewModel {
 
    @Published
    private(set) var state: EmptyWalletState
    
    init() {
        let dataSource = [
            CardDataSource(title: "Don't have \nan account?",
                           bgGradient: [.red, Color.LL.orange],
                           bgImage: Image(componentAsset: "Gradient-Circle"),
                           buttonText: "CREATE",
                           icon: Image(systemName: "plus"),
                           iconColor: .purple,
                           action: .signIn),
            CardDataSource(title: "Already have \nan account?",
                           bgGradient: [Color(hex: "#659EAF"), Color(hex: "#88CBE1")],
                           bgImage: Image(componentAsset: "Gradient-Rect"),
                           buttonText: "IMPORT",
                           icon: Image(systemName: "arrow.forward.to.line"),
                           iconColor: .yellow,
                           action: .signUp)
        ]
        state = EmptyWalletState(dataSource: dataSource)
    }
    
    func trigger(_ input: EmptyWalletAction) {
        switch input {
        case .signUp:
            
            break
        case .signIn:
            break
        }
    }
}
