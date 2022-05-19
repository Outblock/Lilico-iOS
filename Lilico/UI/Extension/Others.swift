//
//  Others.swift
//  Lilico
//
//  Created by Selina on 19/5/2022.
//

import Foundation
import SwiftUI

func overrideNavigationAppearance() {
    // 设置样式 iOS 15生效
    let coloredAppearance = UINavigationBarAppearance()
    coloredAppearance.configureWithOpaqueBackground()
    coloredAppearance.backgroundColor = .clear
    coloredAppearance.shadowColor = .clear
    let titleAttributed: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.clear,
    ]

    coloredAppearance.titleTextAttributes = titleAttributed

    let backButtonAppearance = UIBarButtonItemAppearance()
    backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    coloredAppearance.backButtonAppearance = backButtonAppearance

    let backImage = UIImage(systemName: "arrow.backward")
    coloredAppearance.setBackIndicatorImage(backImage,
                                            transitionMaskImage: backImage)
    UINavigationBar.appearance().compactAppearance = coloredAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
}
