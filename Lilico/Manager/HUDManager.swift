//
//  HUDManager.swift
//  Lilico
//
//  Created by Hao Fu on 4/1/22.
//

import Foundation
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
}
