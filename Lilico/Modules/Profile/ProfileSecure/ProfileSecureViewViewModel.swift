//
//  ProfileSecureViewViewModel.swift
//  Lilico
//
//  Created by Selina on 5/8/2022.
//

import SwiftUI

class ProfileSecureViewModel: ObservableObject {
    @Published var isBionicEnabled: Bool = SecurityManager.shared.isBionicEnabled
    @Published var isPinCodeEnabled: Bool = SecurityManager.shared.isPinCodeEnabled
    
    func changeBionicAction(_ isEnabled: Bool) {
        if SecurityManager.shared.isBionicEnabled == isEnabled {
            return
        }
        
        if !isEnabled {
            SecurityManager.shared.disableBionic()
            isBionicEnabled = false
            return
        }
        
        Task {
            let result = await SecurityManager.shared.enableBionic()
            if !result {
                DispatchQueue.main.async {
                    self.isBionicEnabled = false
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isBionicEnabled = true
            }
        }
    }
    
    func resetPinCodeAction() {
        if SecurityManager.shared.isPinCodeEnabled {
            if !SecurityManager.shared.disablePinCode() {
                HUD.error(title: "disable_pin_code_failed".localized)
                return
            }
            
            HUD.success(title: "pin_code_disabled".localized)
            isPinCodeEnabled = false
            return
        }
        
        Router.route(to: RouteMap.PinCode.pinCode)
    }
    
    func refreshPinCodeStatusAction() {
        isPinCodeEnabled = SecurityManager.shared.isPinCodeEnabled
    }
}
