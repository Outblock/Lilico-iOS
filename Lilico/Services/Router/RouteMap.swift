//
//  RouterMap.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import SwiftUIX

enum RouteMap {
    
}

// MARK: - Restore Login

extension RouteMap {
    enum RestoreLogin {
        case root
        case restoreManual
    }
}

extension RouteMap.RestoreLogin: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RestoreWalletView())
        case .restoreManual:
            navi.push(content: InputMnemonicView())
        }
    }
}
