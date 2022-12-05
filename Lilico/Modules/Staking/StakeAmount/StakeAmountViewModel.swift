//
//  StakeAmountViewModel.swift
//  Lilico
//
//  Created by Selina on 2/12/2022.
//

import SwiftUI

extension StakeAmountViewModel {
    enum ErrorType {
        case none
        case insufficientBalance
        case belowMinimum
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            case .belowMinimum:
                // TODO: Use localized to replace
                return "The balance cannot be less than 0.01"
            }
        }
    }
}

class StakeAmountViewModel: ObservableObject {
    @Published var provider: StakingProvider
    
    @Published var inputText: String = ""
    @Published var inputTextNum: Double = 0
    @Published var balance: Double = 0
    @Published var showConfirmView: Bool = false
    @Published var errorType: StakeAmountViewModel.ErrorType = .none
    
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
    
    var isReadyForStake: Bool {
        return errorType == .none && inputTextNum > 0
    }
    
    init(provider: StakingProvider) {
        self.provider = provider
        balance = WalletManager.shared.getBalance(bySymbol: "flow")
    }
    
    private func refreshState() {
        if inputTextNum > balance {
            errorType = .insufficientBalance
            return
        }
        
        if balance - inputTextNum < 0.001 {
            errorType = .belowMinimum
            return
        }
        
        errorType = .none
    }
}

extension StakeAmountViewModel {
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
        refreshState()
    }
    
    func percentAction(percent: Double) {
        inputText = "\((balance * percent).formatCurrencyString(digits: 2))"
    }
    
    func stakeBtnAction() {
        showConfirmView = true
    }
}
