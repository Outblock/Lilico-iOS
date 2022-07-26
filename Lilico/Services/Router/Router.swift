//
//  Router.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI

protocol RouterTarget {
    func onPresent(navi: UINavigationController)
}

// MARK: - Public

extension Router {
    static func route(to target: RouterTarget) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                target.onPresent(navi: navi)
            }
        }
    }
    
    static func pop(animated: Bool = true) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                navi.popViewController(animated: animated)
            }
        }
    }
    
    static func popToRoot(animated: Bool = true) {
        safeMainThreadCall {
            if let navi = topNavigationController() {
                navi.popToRootViewController(animated: animated)
            }
        }
    }
    
    static func dismiss(animated: Bool = true) {
        safeMainThreadCall {
            topPresentedController().presentingViewController?.dismiss(animated: animated)
        }
    }
}

// MARK: - Private

class Router {
    private static var coordinator = (UIApplication.shared.delegate as! AppDelegate).coordinator
    
    private static func topPresentedController() -> UIViewController {
        var vc = coordinator.window.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        
        return vc!
    }
    
    private static func topNavigationController() -> UINavigationController? {
        if let navi = topPresentedController() as? UINavigationController {
            return navi
        }
        
        return coordinator.rootNavi
    }
    
    private static func safeMainThreadCall(_ call: @escaping () -> Void) {
        if Thread.isMainThread {
            call()
        } else {
            DispatchQueue.main.async {
                call()
            }
        }
    }
}
