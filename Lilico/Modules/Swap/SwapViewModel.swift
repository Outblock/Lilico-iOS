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
    
    var oldInputFromText: String = ""
    var oldInputToText: String = ""
    
    @Published var fromToken: TokenModel?
    @Published var toToken: TokenModel?
    
    var fromAmount: Double {
        return Double(inputFromText) ?? 0
    }
    
    var toAmount: Double {
        return Double(inputToText) ?? 0
    }
    
    var fromTokenRate: Double {
        return CoinRateCache.cache.getSummary(for: fromToken?.symbol ?? "")?.getLastRate() ?? 0
    }
    
    var toTokenRate: Double {
        return CoinRateCache.cache.getSummary(for: toToken?.symbol ?? "")?.getLastRate() ?? 0
    }
    
    var fromPriceAmountString: String {
        return (fromAmount * fromTokenRate).currencyString
    }
}

extension SwapViewModel {
    private func requestEstimate(isFromInput: Bool) {
        guard let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        if fromAmount == 0, toAmount == 0 {
            return
        }
        
        Task {
            do {
                let request = SwapEstimateRequest(inToken: fromToken.contractId, outToken: toToken.contractId, inAmount: isFromInput ? fromAmount : nil, outAmount: isFromInput ? nil : toAmount)
                let response: SwapEstimateResponse = try await Network.request(LilicoAPI.Other.swapEstimate(request))
                
                DispatchQueue.main.async {
                    if isFromInput {
                        self.oldInputToText = "\(response.tokenOutAmount.currencyString)"
                        self.inputToText = "\(response.tokenOutAmount.currencyString)"
                    } else {
                        self.oldInputFromText = "\(response.tokenInAmount.currencyString)"
                        self.inputFromText = "\(response.tokenInAmount.currencyString)"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    DispatchQueue.main.async {
                        HUD.error(title: "swap_request_failed".localized)
                    }
                }
            }
        }
    }
    
    private func refreshInput() {
        
    }
}

extension SwapViewModel {
    func inputFromTextDidChangeAction(text: String) {
        if text == oldInputFromText {
            return
        }
        
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputFromText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputFromText = filtered
            }
        } else {
            inputFromText = filtered
        }
        
        oldInputFromText = inputFromText
        refreshInput()
        requestEstimate(isFromInput: true)
    }
    
    func inputToTextDidChangeAction(text: String) {
        if text == oldInputToText {
            return
        }
        
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputToText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputToText = filtered
            }
        } else {
            inputToText = filtered
        }
        
        oldInputToText = inputToText
        refreshInput()
        requestEstimate(isFromInput: false)
    }
    
    func selectTokenAction(isFrom: Bool) {
        var disableTokens = [TokenModel]()
        if let toToken = toToken, isFrom {
            disableTokens.append(toToken)
        }
        
        if let fromToken = fromToken, !isFrom {
            disableTokens.append(fromToken)
        }
        
        Router.route(to: RouteMap.Wallet.selectToken(isFrom ? fromToken : toToken, disableTokens, { selectedToken in
            if isFrom {
                self.fromToken = selectedToken
            } else {
                self.toToken = selectedToken
            }
            
            self.requestEstimate(isFromInput: isFrom)
        }))
    }
}
