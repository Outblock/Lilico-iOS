//
//  Font.swift
//  Lilico
//
//  Created by Selina on 19/5/2022.
//

import Foundation
import SwiftUI

extension Font {
    enum LL {
//        case largeTitle
//        case title
//        case title2
//        case title3
//        case headline
//        case subheadline
//        case body
//        case callout
//        case footnote
//        case caption
//        case caption2

        static let largeTitle = Font.custom("Montserrat", size: 36, relativeTo: .largeTitle)
        static let largeTitle2 = Font.custom("Montserrat", size: 22, relativeTo: .largeTitle)
        static let largeTitle3 = Font.custom("Montserrat", size: 18, relativeTo: .largeTitle)
        static let mindTitle = Font.custom("Montserrat", size: 16, relativeTo: .largeTitle)
        
        static let title = Font.custom("Inter", relativeTo: .title)
        static let title2 = Font.custom("Inter", relativeTo: .title2)
        static let title3 = Font.custom("Inter", relativeTo: .title3)
        static let headline = Font.custom("Inter", relativeTo: .headline)
        static let subheadline = Font.custom("Inter", relativeTo: .subheadline)
        static let body = Font.custom("Inter", size: 14, relativeTo: .body)
        static let callout = Font.custom("Inter", relativeTo: .callout)
        static let footnote = Font.custom("Inter", relativeTo: .footnote)
        static let caption = Font.custom("Inter", relativeTo: .caption)
        static let caption2 = Font.custom("Inter", relativeTo: .caption2)
        
        
    }
}

/*
 100 - Thin
 200 - Extra Light (Ultra Light)
 300 - Light
 400 - Regular (Normal、Book、Roman)
 500 - Medium
 600 - Semi Bold (Demi Bold)
 700 - Bold
 800 - Extra Bold (Ultra Bold)
 900 - Black (Heavy)
 */

extension Font {
    static func inter(size: CGFloat = 16, weight: Weight = .regular) -> Font {
        return Font.custom("Inter", size: size).weight(weight)
    }
    
    static func W700(size: CGFloat = 16) -> Font {
        return Font.inter(size: size, weight: .bold)
    }
}

extension Font.Weight {
    static let w100 = Font.Weight.thin
    static let w200 = Font.Weight.ultraLight
    static let w300 = Font.Weight.light
    static let w400 = Font.Weight.regular
    
    static let w500 = Font.Weight.medium
    static let w600 = Font.Weight.semibold
    static let w700 = Font.Weight.bold
    static let w800 = Font.Weight.heavy
    static let w900 = Font.Weight.black
}


