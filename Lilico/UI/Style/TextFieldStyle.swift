//
//  TextFieldStyle.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation
import SwiftUI

class TextFieldStyle {
    static let primary: VTextFieldModel = {
        var model: VTextFieldModel = .init()

        model.colors.background = .clear
        model.colors.border = .init(enabled: .gray,
                                    focused: .black,
                                    success: .black,
                                    error: .black,
                                    disabled: .clear)

        model.colors.clearButtonBackground = .init(enabled: .separator,
                                                   focused: .separator,
                                                   success: .separator,
                                                   error: .separator,
                                                   pressedEnabled: .separator.opacity(0.5),
                                                   pressedFocused: .separator.opacity(0.5),
                                                   pressedSuccess: .separator.opacity(0.5),
                                                   pressedError: .separator.opacity(0.5),
                                                   disabled: .separator.opacity(0.5))

        model.colors.clearButtonIcon = .clear
//            .init(enabled: Color.LL.background,
//                                             focused: Color.LL.background,
//                                             success: Color.LL.background,
//                                             error: Color.LL.background,
//                                             pressedEnabled: Color.LL.background.opacity(0.5),
//                                             pressedFocused: Color.LL.background.opacity(0.5),
//                                             pressedSuccess: Color.LL.background.opacity(0.5),
//                                             pressedError: Color.LL.background.opacity(0.5),
//                                             disabled: Color.LL.background.opacity(0.5),
//                                             pressedOpacity: 0.5,
//                                             disabledOpacity: 0.1)

        model.layout.cornerRadius = 16
        model.layout.height = 60
        model.layout.headerFooterSpacing = 8
        return model
    }()
}
