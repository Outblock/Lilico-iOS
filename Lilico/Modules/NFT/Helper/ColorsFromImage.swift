//
//  ColorsFromImage.swift
//  Lilico
//
//  Created by cat on 2022/6/8.
//

import Foundation
import SwiftUI
import ColorKit

extension UIImage {
    func colors() async -> [Color] {
//        return await withCheckedContinuation { continuation in
//            DispatchQueue.global().async {
//                guard let colors = ColorThief.getPalette(from: self, colorCount: 6, quality: 1, ignoreWhite: false) else {
//                    DispatchQueue.main.async {
//                        continuation.resume(returning: [])
//                    }
//
//                    return
//                }
//                DispatchQueue.main.async {
//                    let result = colors.map { Color(uiColor: $0.makeUIColor()) }
//                    continuation.resume(returning: result)
//                }
//            }
//        }
        
        guard let colors = try? dominantColors(),
              let palette = ColorPalette(orderedColors: colors, ignoreContrastRatio: true) else {
            return [.LL.text]
        }
        
        return [Color(palette.background), Color(palette.primary), (palette.secondary != nil) ? Color(palette.secondary!) : .LL.text]
    }
}
