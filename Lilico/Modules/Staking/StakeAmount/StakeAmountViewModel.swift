//
//  StakeAmountViewModel.swift
//  Lilico
//
//  Created by Selina on 2/12/2022.
//

import SwiftUI

class StakeAmountViewModel: ObservableObject {
    @Published var provider: StakingProvider
    
    @Published var inputText: String = ""
    @Published var inputTextNum: Double = 0
    @Published var balance: Double = 0
    @Published var showConfirmView: Bool = false
    
    var inputNumAsUSD: Double {
        let rate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return inputTextNum * rate
    }
    
    var inputNumAsCurrencyString: String {
        return "\(CurrencyCache.cache.currencySymbol)\(inputNumAsUSD.formatCurrencyString(digits: 2, considerCustomCurrency: true)) \(CurrencyCache.cache.currentCurrency.rawValue)"
    }
    
    var yearRewardFlowString: String {
        return (inputTextNum * (1 + provider.apyYear)).formatCurrencyString(digits: 2)
    }
    
    var yearRewardWithCurrencyString: String {
        let numString = (inputNumAsUSD * (1 + provider.apyYear)).formatCurrencyString(digits: 2, considerCustomCurrency: true)
        return "\(CurrencyCache.cache.currencySymbol)\(numString) \(CurrencyCache.cache.currentCurrency.rawValue)"
    }
    
    init(provider: StakingProvider) {
        self.provider = provider
        balance = WalletManager.shared.getBalance(bySymbol: "flow")
    }
    
    func inputTextDidChangeAction(text: String) {
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputText = filtered
            }
        } else {
            inputText = filtered
        }
        
        inputTextNum = Double(inputText) ?? 0
    }
}
