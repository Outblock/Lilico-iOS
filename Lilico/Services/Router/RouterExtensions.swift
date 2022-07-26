//
//  RouterExtensions.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import SwiftUI
import UIKit

extension View {
    @ViewBuilder func applyRouteable(_ config: RouterContentDelegate) -> some View {
        navigationBarBackButtonHidden(true)
            .navigationBarHidden(config.isNavigationBarHidden)
            .navigationTitle(config.title)
            .navigationBarTitleDisplayMode(config.navigationBarTitleDisplayMode)
    }
}

extension UINavigationController {
    func push(content: some RouteableView, animated: Bool = true) {
        let vc = RouteableUIHostingController(rootView: content)
        self.pushViewController(vc, animated: animated)
    }
}

extension UIViewController {
    func present(content: some RouteableView, animated: Bool = true, wrapWithNavi: Bool = true) {
        let vc = RouteableUIHostingController(rootView: content)
        let navi = UINavigationController(rootViewController: vc)
        self.present(navi, animated: animated)
    }
}
