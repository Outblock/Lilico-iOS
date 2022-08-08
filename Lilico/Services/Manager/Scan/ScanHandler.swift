//
//  ScanHandler.swift
//  Lilico
//
//  Created by Selina on 8/8/2022.
//

import UIKit
import SwiftUI

class ScanHandler {
    static func scan() {
        Router.route(to: RouteMap.Wallet.scan({ data, vc in
            switch data {
            case.walletConnect(let string):
                vc.stopRunning()
                vc.presentingViewController?.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        WalletConnectManager.shared.connect(link: string)
                    }
                })
            default:
                break
            }
        }))
    }
}
