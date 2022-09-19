//
//  InboxViewModel.swift
//  Lilico
//
//  Created by Selina on 19/9/2022.
//

import SwiftUI
import SwiftUIPager

extension InboxViewModel {
    enum TabType: Int, CaseIterable {
        case token
        case nft
    }
}

class InboxViewModel: ObservableObject {
    @Published var tabType: InboxViewModel.TabType = .token
    @Published var page: Page = .first()
    @Published var tokenList: [InboxToken] = []
    @Published var nftList: [InboxNFT] = []
}

extension InboxViewModel {
    func changeTabTypeAction(type: InboxViewModel.TabType) {
        
    }
}
