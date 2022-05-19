//
//  Color.swift
//  Lilico-lite
//
//  Created by Hao Fu on 27/11/21.
//

import Foundation
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

// MARK: - Custom Color

extension Color {
    enum LL {
        static let background = Color("Background")
        static let rebackground = Color("Rebacground")
//        static let primary = Color("Primary")
        static let orange = Color("Orange")
        static let blue = Color("Blue")
        static let yellow = Color("Yellow")

        static let error = Color("Error")
        static let success = Color("Success")
        static let outline = Color("Outline")
        static let disable = Color("Disable")
        static let note = Color("Note")

        static let frontColor = Color("FrontColor")

        static let text = Color("Text")

        static let warning2 = Color("Warning2")
        static let warning6 = Color("Warning6")

        static let bgForIcon = Color("BgForIcon")

        static let deepBg = Color("DeepBackground")
        
        static let neutrals1 = Color("Neutrals1")
        
        
        /// The primary color palette is used across all the iteractive elemets such as CTA’s(Call to The Action), links, inputs,active states,etc
        enum Primary {
            static let salmon1 = Color("primary.salmon1")
            static let salmonPrimary = Color("primary.salmonPrimary")
            static let salmon3 = Color("primary.salmon3")
            static let salmon4 = Color("primary.salmon4")
            static let salmon5 = Color("primary.salmon5")
        }
        
        /// The neutral color palette is used as supportig secondary colors in backgrounds, text colors,  seperators, models, etc
        enum Secondary {
            static let violet1 = Color("secondary.violet1")
            static let violetDiscover = Color("secondary.violetDiscover")
            static let violet3 = Color("secondary.violet3")
            static let violet4 = Color("secondary.violet4")
            static let violet5 = Color("secondary.violet5")
            
            static let navy1 = Color("secondary.navy1")
            static let navyWallet = Color("secondary.navyWallet")
            static let navy3 = Color("secondary.navy3")
            static let navy4 = Color("secondary.navy4")
            static let navy5 = Color("secondary.navy5")
            
            static let mango1 = Color("secondary.mango1")
            static let mangoNFT = Color("secondary.mangoNFT")
            static let mango3 = Color("secondary.mango3")
            static let mango4 = Color("secondary.mango4")
            static let mango5 = Color("secondary.mango5")
        }
        
        
        /// The neutral color palette is used as supportig secondary colors in backgrounds, text colors,  seperators, models, etc
        enum Neutrals {
            static let neutrals1 = Color("neutrals.1")
            static let text = Color("neutrals.text")
            static let neutrals3 = Color("neutrals.3")
            static let neutrals4 = Color("neutrals.4")
            static let note = Color("neutrals.note")
            static let neutrals6 = Color("neutrals.6")
            
            static let neutrals7 = Color("neutrals.7")
            static let neutrals8 = Color("neutrals.8")
            static let neutrals9 = Color("neutrals.9")
            static let neutrals10 = Color("neutrals.10")
            static let outline = Color("neutrals.outline")
            static let background = Color("neutrals.background")
        }
        
        /// These colors depict an emotion of positivity. Generally used across success, complete states.
        enum Success {
            static let success1 = Color("success.1")
            static let success2 = Color("success.2")
            static let success3 = Color("success.3")
            static let success4 = Color("success.4")
            static let success5 = Color("success.5")
        }
        
        enum Warning {
            static let warning1 = Color("warning.1")
            static let warning2 = Color("warning.2")
            static let warning3 = Color("warning.3")
            static let warning4 = Color("warning.4")
            static let warning5 = Color("warning.5")
            static let warning6 = Color("warning.6")
        }
        
        enum Shades {
            static let front = Color("shades.front")
            static let shades2 = Color("shades.2")
        }
        
        
    }
    
    
}
