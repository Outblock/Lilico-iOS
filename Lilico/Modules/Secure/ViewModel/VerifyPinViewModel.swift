//
//  VerifyPinViewModel.swift
//  Lilico
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI
import BiometricAuthentication

extension VerifyPinViewModel {
    typealias VerifyCallback = (Bool) -> ()
    
    enum VerifyType {
        case pin
        case bionic
    }
}

class VerifyPinViewModel: ObservableObject {
    @Published var currentVerifyType: VerifyPinViewModel.VerifyType = .pin
    @Published var inputPin: String = ""
    @Published var pinCodeErrorTimes: Int = 0
    var callback: VerifyCallback? = nil
    
    init(callback: VerifyCallback?) {
        self.callback = callback
        
        let type = SecurityManager.shared.securityType
        switch type {
        case .both, .bionic:
            currentVerifyType = .bionic
        case .pin:
            currentVerifyType = .pin
        default:
            break
        }
    }
}

extension VerifyPinViewModel {
    func changeVerifyTypeAction(type: VerifyPinViewModel.VerifyType) {
        if currentVerifyType != type {
            currentVerifyType = type
        }
    }
    
    func verifyPinAction() {
        let result = SecurityManager.shared.authPinCode(inputPin)
        if !result {
            pinVerifyFailed()
            return
        }
        
        verifySuccess()
    }
    
    private func pinVerifyFailed() {
        inputPin = ""
        withAnimation(.default) {
            pinCodeErrorTimes += 1
        }
    }
    
    func verifyBionicAction() {
        Task {
            let result = await SecurityManager.shared.authBionic()
            DispatchQueue.main.async {
                if result {
                    self.verifySuccess()
                }
            }
        }
    }
    
    private func verifySuccess() {
        if let customCallback = callback {
            customCallback(true)
        }
    }
}
