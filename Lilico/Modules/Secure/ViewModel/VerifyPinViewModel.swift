//
//  VerifyPinViewModel.swift
//  Lilico
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI
import BiometricAuthentication

extension VerifyPinViewModel {
    enum VerifyType {
        case pin
        case bionic
    }
    
    enum BionicType {
        case none
        case faceid
        case touchid
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .faceid:
                return "face_id".localized
            case .touchid:
                return "touch_id".localized
            }
        }
    }
}

typealias VerifyCallback = (Bool) -> ()

class VerifyPinViewModel: ObservableObject {
    @Published var currentVerifyType: VerifyPinViewModel.VerifyType = .pin
    @Published var inputPin: String = ""
    @Published var pinCodeErrorTimes: Int = 0
    var callback: VerifyCallback?
    
    var supportedBionic: BionicType {
        if BioMetricAuthenticator.shared.faceIDAvailable() {
            return .faceid
        }

        if BioMetricAuthenticator.shared.touchIDAvailable() {
            return .touchid
        }

        return .none
    }
    
    init() {
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
        inputPin = ""
        withAnimation(.default) {
            pinCodeErrorTimes += 1
        }
    }
    
    func verifyBionicAction() {
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { result in
            switch result {
            case .success:
                self.verifySuccess()
            case .failure(let error):
                debugPrint("bionic error: \(error)")
                BionicErrorHandler.handleError(error)
            }
        }
    }
    
    private func verifySuccess() {
        if let customCallback = callback {
            customCallback(true)
            return
        }
        
        Router.coordinator.showRootView()
    }
}
