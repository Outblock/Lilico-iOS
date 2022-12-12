//
//  StakingDetailViewModel.swift
//  Lilico
//
//  Created by Selina on 13/12/2022.
//

import SwiftUI
import Combine

class StakingDetailViewModel: ObservableObject {
    @Published var provider: StakingProvider
    @Published var node: StakingNode
    
    init(provider: StakingProvider, node: StakingNode) {
        self.provider = provider
        self.node = node
    }
    
    var availableAmount: Double {
        let balance = WalletManager.shared.getBalance(bySymbol: "flow")
        return balance - node.stakingCount
    }
}
