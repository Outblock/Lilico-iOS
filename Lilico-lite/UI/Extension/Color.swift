//
//  Color.swift
//  Lilico-lite
//
//  Created by Hao Fu on 27/11/21.
//

import SwiftUI

extension Color {
    init(hex: UInt64, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(hex: String, alpha: Double = 1) {
//        if (hex.hasPrefix("#")) {
//
//        }
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: int, alpha: alpha)
    }
}
