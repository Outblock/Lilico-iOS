//
//  TabBarPageModel.swift
//  Test
//
//  Created by Selina on 26/5/2022.
//

import SwiftUI

struct TabBarPageModel<T: Hashable> {
    let tag: T
    let iconName: String
    let color: Color
    let view: () -> AnyView
    let contextMenu: (() -> AnyView)?
    
    init(tag: T, iconName: String, color: Color, view: @escaping () -> AnyView, contextMenu: (() -> AnyView)? = nil) {
        self.tag = tag
        self.iconName = iconName
        self.color = color
        self.view = view
        self.contextMenu = contextMenu
    }
}
