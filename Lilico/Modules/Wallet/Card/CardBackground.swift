//
//  CardBackground.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import Foundation
import SwiftUI

enum CardBackground {
    case image(image: SwiftUI.Image)
    case fade(image: SwiftUI.Image)
    case fluid
    
    @ViewBuilder
    func renderView() -> some View {
        switch self {
        case .fluid:
            FluidView()
        case let .fade(image):
            FadeAnimationBackground(image: image)
        case let .image(image):
             image
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    struct Key: PreferenceKey {
        public typealias Value = CardBackground
        public static var defaultValue = CardBackground.fluid
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }
}
