//
//  TextFieldStyle.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation

class TextFieldStyle {
    static let primary: VTextFieldModel = {
        var model: VTextFieldModel = .init()

        model.colors.background = .clear
        model.colors.border = .init(enabled: .gray,
                                    focused: .black,
                                    success: .green,
                                    error: .red,
                                    disabled: .clear)
        model.layout.cornerRadius = 16
        model.layout.height = 60
        model.layout.headerFooterSpacing = 8
        return model
    }()
}
