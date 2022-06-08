//
//  ColorsFromImage.swift
//  Lilico
//
//  Created by cat on 2022/6/8.
//

import Foundation
import SwiftUI

extension UIImage {
    func colors() async -> [Color] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                guard let colors = ColorThief.getPalette(from: self, colorCount: 7, quality: 1, ignoreWhite: true) else {
                    DispatchQueue.main.async {
                        continuation.resume(returning: [])
                    }
                    
                    return
                }
                DispatchQueue.main.async {
                    let result = colors.map { Color(uiColor: $0.makeUIColor()) }
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
