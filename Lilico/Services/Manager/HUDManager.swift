//
//  HUDManager.swift
//  Lilico
//
//  Created by Hao Fu on 4/1/22.
//

import UIKit
import SwiftUI
import SPIndicator

class HUD {
    static func present(title: String,
                        message: String? = nil,
                        preset: SPIndicatorIconPreset = .done,
                        haptic: SPIndicatorHaptic = .success,
                        from _: SPIndicatorPresentSide = .top)
    {
        DispatchQueue.main.async {
            SPIndicator.present(title: title, message: message, preset: preset, haptic: haptic, from: .top, completion: nil)
        }
    }

    static func success(title: String, message: String? = nil, preset: SPIndicatorIconPreset = .done, haptic: SPIndicatorHaptic = .success) {
        HUD.present(title: title, message: message, preset: preset, haptic: haptic)
    }

    static func error(title: String, message: String? = nil, preset: SPIndicatorIconPreset = .error, haptic: SPIndicatorHaptic = .error) {
        HUD.present(title: title, message: message, preset: preset, haptic: haptic)
    }

    static func debugSuccess(title: String, message: String? = nil, preset: SPIndicatorIconPreset = .done, haptic: SPIndicatorHaptic = .success) {
        #if DEBUG
            HUD.present(title: title, message: message, preset: preset, haptic: haptic)
        #endif
    }

    static func debugError(title: String, message: String? = nil, preset: SPIndicatorIconPreset = .error, haptic: SPIndicatorHaptic = .error) {
        #if DEBUG
            HUD.present(title: title, message: message, preset: preset, haptic: haptic)
        #endif
    }
    
    static func setupProgressHUD() {
        ProgressHUD.animationType = .multipleCirclePulse
        ProgressHUD.colorAnimation = UIColor(Color.LL.Primary.salmonPrimary)
        ProgressHUD.colorStatus = UIColor(Color.LL.Primary.salmonPrimary)
        ProgressHUD.fontStatus = .systemFont(ofSize: 19, weight: .medium)
    }
    
    static func loading(_ title: String = "", interaction: Bool = false) {
        ProgressHUD.show(title, interaction: interaction)
    }
    
    static func dismissLoading() {
        ProgressHUD.dismiss()
    }
}
