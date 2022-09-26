//
//  SwapViewModel.swift
//  Lilico
//
//  Created by Selina on 23/9/2022.
//

import SwiftUI

class SwapViewModel: ObservableObject {
    @Published var inputFromText: String = ""
    @Published var inputToText: String = ""
}

extension SwapViewModel {
    func inputTextDidChangeAction(text: String) {
        
    }
    
    func selectTokenAction(isFrom: Bool) {
        Router.route(to: RouteMap.Wallet.selectToken(nil, [], { selectedToken in
            
        }))
    }
}
