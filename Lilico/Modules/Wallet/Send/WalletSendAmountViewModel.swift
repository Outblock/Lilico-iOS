//
//  WalletSendAmountViewModel.swift
//  Lilico
//
//  Created by Selina on 13/7/2022.
//

import Foundation
import SwiftUI
import Flow
import Stinsen
import Combine

extension WalletSendAmountView {
    enum ExchangeType {
        case token
        case dollar
    }
    
    enum ErrorType {
        case none
        case insufficientBalance
        case formatError
        case invalidAddress
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            case .formatError:
                return "format_error".localized
            case .invalidAddress:
                return "invalid_address".localized
            }
        }
    }
}

class WalletSendAmountViewModel: ObservableObject {
    @RouterObject var router: WalletSendCoordinator.Router?
    
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
    
    private var isSending = false
    private var cancelSets = Set<AnyCancellable>()
    
    private var addressIsValid: Bool?
    
    init(target: Contact, token: TokenModel) {
        self.targetContact = target
        self.token = token
        
        WalletManager.shared.$coinBalances.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshTokenData()
                self?.refreshInput()
            }
        }.store(in: &cancelSets)
        
        checkAddress()
    }
    
    var amountBalanceAsDollar: Double {
        return coinRate * amountBalance
    }
    
    var isReadyForSend: Bool {
        return errorType == .none && inputText.isNumber && addressIsValid == true
    }
}

extension WalletSendAmountViewModel {
    private func checkAddress() {
        Task {
            if let address = targetContact.address {
                let isValid = await FlowNetwork.addressVerify(address: address)
                DispatchQueue.main.async {
                    self.addressIsValid = isValid
                    if isValid == false {
                        self.errorType = .invalidAddress
                    }
                }
            }
        }
    }
    
    private func refreshTokenData() {
        amountBalance = WalletManager.shared.getBalance(bySymbol: token.symbol ?? "")
        coinRate = CoinRateCache.cache.getSummary(for: token.symbol ?? "")?.getLastRate() ?? 0
    }
    
    private func refreshInput() {
        if errorType == .invalidAddress {
            return
        }
        
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
    
    private func saveToRecentLlist() {
        RecentListCache.cache.append(contact: targetContact)
    }
}

extension WalletSendAmountViewModel {
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
    
    func sendAction() {
        if isSending {
            return
        }
        
        let successBlock = {
            DispatchQueue.main.async {
                self.isSending = false
                HUD.dismissLoading()
                HUD.success(title: "sent_successfully".localized)
                self.router?.popToRoot()
                
                Task {
                    try? await WalletManager.shared.fetchBalance()
                }
            }
        }
        
        let failureBlock = {
            DispatchQueue.main.async {
                self.isSending = false
                HUD.dismissLoading()
                HUD.error(title: "send_failed".localized)
            }
        }
        
        saveToRecentLlist()
        
        isSending = true
        HUD.loading("sending".localized)
        
        Task {
            do {
                let id = try await FlowNetwork.transferToken(to: Flow.Address(hex: targetContact.address ?? "0x"), amount: inputTokenNum)
                let result = try await id.onceSealed()
                
                if result.isFailed {
                    debugPrint("WalletSendAmountViewModel -> sendAction result failed: \(result.errorMessage)")
                    failureBlock()
                    return
                }
                
                if result.isComplete {
                    successBlock()
                    return
                }
            } catch {
                debugPrint("WalletSendAmountViewModel -> sendAction error: \(error)")
                failureBlock()
            }
        }
    }
    
    func changeTokenModelAction(token: TokenModel) {
        LocalUserDefaults.shared.recentToken = token.symbol
        
        self.token = token
        refreshTokenData()
        refreshInput()
    }
}