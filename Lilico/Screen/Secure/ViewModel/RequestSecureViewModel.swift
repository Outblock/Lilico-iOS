//
//  RequestSecureViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import Foundation
import Stinsen
import BiometricAuthentication

class RequestSecureViewModel: ViewModel {
    @Published
    private(set) var state: RequestSecureView.ViewState = .init()

    @RouterObject
    var router: SecureCoordinator.Router?
    
    @RouterObject
    var homeRouter: HomeCoordinator.Router?

    init() {
        if BioMetricAuthenticator.shared.faceIDAvailable() {
            // device supports face id recognition.
            state = .init(biometric: .faceId)
        }
        
        if BioMetricAuthenticator.shared.touchIDAvailable() {
            // device supports touch id authentication
            state = .init(biometric: .touchId)
        }
        
        if !BioMetricAuthenticator.canAuthenticate() {
            state = .init(biometric: .none)
        }
    }

    func trigger(_ input: RequestSecureView.Action) {
        switch input {
        case .faceID:
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Need your permission") { (result) in
                switch result {
                case .success(_):
                    self.homeRouter?.popToRoot()
                case .failure(let error):
                    print("Authentication Failed")
                    print(error)
                }
            }
        case .pin:
            router?.route(to: \.pinCode)
        }
    }
}
