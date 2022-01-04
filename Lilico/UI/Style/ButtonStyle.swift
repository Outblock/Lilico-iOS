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

        model.colors.textContent = .init(enabled: Color.LL.background,
                                         pressed: Color.LL.background.opacity(0.5),
                                         loading: Color.LL.background,
                                         disabled: Color.LL.background)

        model.colors.background = .init(enabled: Color.LL.rebackground,
                                        pressed: Color.LL.rebackground.opacity(0.5),
                                        loading: Color.LL.rebackground,
                                        disabled: .gray)

        model.layout.cornerRadius = 16
        return model
    }()

    public static let border: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.layout.borderWidth = 1
        model.colors.textContent = .init(enabled: Color.LL.rebackground,
                                         pressed: Color.LL.rebackground.opacity(0.5),
                                         loading: Color.LL.rebackground,
                                         disabled: Color.LL.rebackground)

        model.colors.background = .clear

        model.colors.border = .init(enabled: Color.LL.rebackground,
                                    pressed: Color.LL.rebackground.opacity(0.5),
                                    loading: Color.LL.rebackground,
                                    disabled: Color.LL.rebackground)

        model.layout.cornerRadius = 16
        return model
    }()

    public static let plain: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

//        model.layout.borderWidth = 1
        model.colors.textContent = .init(enabled: Color.LL.rebackground,
                                         pressed: Color.LL.rebackground.opacity(0.5),
                                         loading: Color.LL.rebackground,
                                         disabled: Color.LL.rebackground)

        model.colors.background = .clear

        model.layout.cornerRadius = 16
        return model
    }()
}
