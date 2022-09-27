//
//  SwapViewModel.swift
//  Lilico
//
//  Created by Selina on 23/9/2022.
//

import SwiftUI

private let TimerDelay: TimeInterval = 0.4

class SwapViewModel: ObservableObject {
    @Published var inputFromText: String = ""
    @Published var inputToText: String = ""
    @Published var fromToken: TokenModel?
    @Published var toToken: TokenModel?
    @Published var isRequesting: Bool = false
    @Published var estimateResponse: SwapEstimateResponse?
    
    var oldInputFromText: String = ""
    var oldInputToText: String = ""
    
    private var timer: Timer?
    private var requestIsFromInput: Bool = true
    
    var buttonState: VPrimaryButtonState {
        if isRequesting {
            return .loading
        }
        
        return isValidToSwap ? .enabled : .disabled
    }
    
    var isValidToSwap: Bool {
        guard fromToken != nil, toToken != nil, fromAmount != 0, toAmount != 0 else {
            return false
        }
        
        // TODO: check balance
        return true
    }
    
    var rateText: String {
        if self.timer?.isValid == true || self.isRequesting {
            return ""
        }
        
        guard let fromToken = fromToken, let toToken = toToken, let response = estimateResponse else {
            return ""
        }
        
        guard let amountIn = response.routes.first??.routeAmountIn, let amountOut = response.routes.first??.routeAmountOut else {
            return ""
        }
        
        return "1 \(fromToken.symbol?.uppercased() ?? "") ≈ \((amountOut / amountIn).currencyString) \(toToken.symbol?.uppercased() ?? "")"
    }
    
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
        requestIsFromInput = isFromInput
        
        guard fromToken != nil, toToken != nil else {
            stopTimer()
            return
        }
        
        if fromAmount == 0, toAmount == 0 {
            stopTimer()
            return
        }
        
        startTimer()
    }
    
    @objc private func doRequestEstimate() {
        guard let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        if fromAmount == 0, toAmount == 0 {
            return
        }
        
        let localIsFromInput = requestIsFromInput
        let localFromAmount = fromAmount
        let localToAmount = toAmount
        
        isRequesting = true
        
        Task {
            do {
                let request = SwapEstimateRequest(inToken: fromToken.contractId, outToken: toToken.contractId, inAmount: localIsFromInput ? fromAmount : nil, outAmount: localIsFromInput ? nil : toAmount)
                let response: SwapEstimateResponse = try await Network.request(LilicoAPI.Other.swapEstimate(request))
                
                DispatchQueue.main.async {
                    self.isRequesting = false
                    
                    if fromToken.contractId != self.fromToken?.contractId || toToken.contractId != self.toToken?.contractId || localIsFromInput != self.requestIsFromInput {
                        // invalid response
                        return
                    }
                    
                    if localIsFromInput, localFromAmount != self.fromAmount {
                        // invalid response
                        return
                    }
                    
                    if !localIsFromInput, localToAmount != self.toAmount {
                        // invalid response
                        return
                    }
                    
                    if localIsFromInput {
                        self.oldInputToText = "\(response.tokenOutAmount.currencyString)"
                        self.inputToText = "\(response.tokenOutAmount.currencyString)"
                    } else {
                        self.oldInputFromText = "\(response.tokenInAmount.currencyString)"
                        self.inputFromText = "\(response.tokenInAmount.currencyString)"
                    }
                    
                    self.estimateResponse = response
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    HUD.error(title: "swap_request_failed".localized)
                }
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        let timer = Timer(timeInterval: TimerDelay, target: self, selector: #selector(doRequestEstimate), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
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
    
    func switchTokenAction() {
        guard let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        UIApplication.shared.endEditing()
        
        self.fromToken = toToken
        self.toToken = fromToken
        self.requestEstimate(isFromInput: !self.requestIsFromInput)
    }
    
    func swapAction() {
        
    }
}
