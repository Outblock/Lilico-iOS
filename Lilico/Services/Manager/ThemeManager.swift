//
//  ThemeManager.swift
//  Lilico
//
//  Created by Selina on 17/5/2022.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var style: ColorScheme?
    @AppStorage("customThemeKey") private var storageThemeKey: String?

    init() {
        reloadStyle()
    }

    private func reloadStyle() {
        style = ColorScheme.fromKey(key: storageThemeKey)
    }

    func setStyle(style: ColorScheme?) {
        if let style = style {
            storageThemeKey = style.key
        } else {
            storageThemeKey = nil
        }

        reloadStyle()
    }
    
    func getUIKitStyle() -> UIUserInterfaceStyle {
        if let style = style {
            return style.toUIKitEnum
        }
        
        return .unspecified
    }
}

extension ColorScheme {
    var key: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "light"
        }
    }

    var desc: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Light"
        }
    }
    
    var toUIKitEnum: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .unspecified
        }
    }

    static func fromKey(key: String?) -> ColorScheme? {
        guard let key = key else {
            return nil
        }

        switch key {
        case ColorScheme.light.key:
            return ColorScheme.light
        case ColorScheme.dark.key:
            return ColorScheme.dark
        default:
            return nil
        }
    }
}
