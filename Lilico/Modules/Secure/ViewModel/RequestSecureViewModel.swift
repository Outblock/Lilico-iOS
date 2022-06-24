//
//  RequestSecureViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import BiometricAuthentication
import Foundation
import Stinsen

class RequestSecureViewModel: ViewModel {
    @Published
    private(set) var state: RequestSecureView.ViewState = .init()

    @RouterObject
    var router: SecureCoordinator.Router?

    @RouterObject
    var homeRouter: WalletCoordinator.Router?

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
            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Need your permission") { result in
                switch result {
                case .success:
                    self.homeRouter?.popToRoot()
                case let .failure(error):
                    print("Authentication Failed")
                    print(error)
                }
            }
        case .pin:
            router?.route(to: \.pinCode)
        }
    }
}
