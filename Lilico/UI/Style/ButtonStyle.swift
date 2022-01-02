//
//  ButtonStyle.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import SwiftUI

class ButtonStyle {
    public static let primary: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.colors.textContent = .init(enabled: .white,
                                         pressed: .white,
                                         loading: .white,
                                         disabled: .white)

        model.colors.background = .init(enabled: .black,
                                        pressed: .black.opacity(0.8),
                                        loading: .black,
                                        disabled: .gray)

        model.layout.cornerRadius = 16
        return model
    }()
}
