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
    
    @Published var isRequesting: Bool = false
    
    var buttonState: VPrimaryButtonState {
        if isRequesting {
            return .loading
        }
        return .enabled
    }
    
    var inputNumAsUSD: Double {
        let rate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return inputTextNum * rate
    }
    
    var inputNumAsCurrencyString: String {
        return "\(CurrencyCache.cache.currencySymbol)\(inputNumAsUSD.formatCurrencyString(digits: 2, considerCustomCurrency: true)) \(CurrencyCache.cache.currentCurrency.rawValue)"
    }
    
    var inputNumAsCurrencyStringInConfirmSheet: String {
        return "\(CurrencyCache.cache.currencySymbol)\(inputNumAsUSD.formatCurrencyString(digits: 2, considerCustomCurrency: true))"
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
        UIApplication.shared.endEditing()
        
        if showConfirmView {
            showConfirmView = false
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showConfirmView = true
        }
    }
    
    func confirmStakeAction() {
        // TODO: 
        return
        if isRequesting {
            return
        }
        
        isRequesting = true
        
        let failureBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "request_failed".localized)
            }
        }
        
        Task {
            do {
                // check staking is enabled
                if try await FlowNetwork.stakingIsEnabled() == false {
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        HUD.error(title: "staking_disabled".localized)
                    }
                    return
                }
                
                // check account staking is setup
                if try await FlowNetwork.accountStakingIsSetup() == false {
                    debugPrint("StakeGuideViewModel: account staking not setup, setup right now.")
                    
                    if try await FlowNetwork.setupAccountStaking() == false {
                        debugPrint("StakeGuideViewModel: setup account staking failed.")
                        failureBlock()
                        return
                    }
                }
                
                // create delegator id
                guard let lilicoProvider = StakingProviderCache.cache.providers.first(where: { $0.isLilico }) else {
                    debugPrint("StakeGuideViewModel: can not find lilico provider.")
                    failureBlock()
                    return
                }
                
                if try await FlowNetwork.createDelegatorId(providerId: lilicoProvider.id) == false {
                    debugPrint("StakeGuideViewModel: createDelegatorId failed.")
                    failureBlock()
                    return
                }
                
                debugPrint("StakeGuideViewModel: delegator id created.")
                DispatchQueue.main.async {
                    HUD.success(title: "yes")
                    self.isRequesting = false
                }
            } catch {
                debugPrint("StakeGuideViewModel: catch error \(error)")
                failureBlock()
            }
        }
    }
}
