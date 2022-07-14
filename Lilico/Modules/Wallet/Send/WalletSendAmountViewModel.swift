//
//  WalletSendAmountViewModel.swift
//  Lilico
//
//  Created by Selina on 13/7/2022.
//

import Foundation
import SwiftUI

extension WalletSendAmountView {
    enum ExchangeType {
        case token
        case dollar
    }
    
    enum ErrorType {
        case none
        case insufficientBalance
        case formatError
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            case .formatError:
                return "format_error".localized
            }
        }
    }
}

class WalletSendAmountViewModel: ObservableObject {
    @Published var targetContact: Contact
    @Published var token: TokenModel
    @Published var amountBalance: Double = 0
    @Published var coinRate: Double = 0
    
    @Published var inputText: String = ""
    @Published var inputTokenNum: Double = 0
    @Published var inputDollarNum: Double = 0
    
    @Published var exchangeType: WalletSendAmountView.ExchangeType = .token
    @Published var errorType: WalletSendAmountView.ErrorType = .none
    
    @Published var showConfirmView: Bool = false
    
    init(target: Contact, token: TokenModel) {
        self.targetContact = target
        self.token = token
        refreshTokenData()
    }
    
    private func refreshTokenData() {
        amountBalance = WalletManager.shared.getBalance(bySymbol: token.symbol ?? "")
        coinRate = CoinRateCache.cache.getSummary(for: token.symbol ?? "")?.getLastRate() ?? 0
    }
    
    var amountBalanceAsDollar: Double {
        return coinRate * amountBalance
    }
    
    var isReadyForSend: Bool {
        return errorType == .none && inputText.isNumber
    }
}

extension WalletSendAmountViewModel {
    private func refreshInput() {
        if inputText.isEmpty {
            errorType = .none
            return
        }
        
        if !inputText.isNumber {
            inputDollarNum = 0
            inputTokenNum = 0
            errorType = .formatError
            return
        }
        
        if exchangeType == .token {
            inputTokenNum = Double(inputText)!
            inputDollarNum = inputTokenNum * coinRate
        } else {
            inputDollarNum = Double(inputText)!
            if coinRate == 0 {
                inputTokenNum = 0
            } else {
                inputTokenNum = inputDollarNum / coinRate
            }
        }
        
        if inputTokenNum > amountBalance {
            errorType = .insufficientBalance
            return
        }
        
        errorType = .none
    }
}

extension WalletSendAmountViewModel {
    func inputTextDidChangeAction(text: String) {
        debugPrint("WalletSendAmountViewModel -> inputTextDidChangeAction: \(text)")
        
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
        
        refreshInput()
    }
    
    func maxAction() {
        exchangeType = .token
        inputText = amountBalance.currencyString
    }
    
    func toggleExchangeTypeAction() {
        if exchangeType == .token, coinRate != 0 {
            exchangeType = .dollar
            inputText = inputDollarNum.currencyString
        } else {
            exchangeType = .token
            inputText = inputTokenNum.currencyString
        }
    }
    
    func nextAction() {
        UIApplication.shared.endEditing()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showConfirmView = true
        }
    }
    
    func changeTokenModelAction(token: TokenModel) {
        LocalUserDefaults.shared.recentToken = token.symbol
        
        self.token = token
        refreshTokenData()
        refreshInput()
    }
}
