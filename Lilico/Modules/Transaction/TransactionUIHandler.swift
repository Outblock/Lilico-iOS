//
//  TransactionUIHandler.swift
//  Lilico
//
//  Created by Selina on 26/8/2022.
//

import UIKit

class TransactionUIHandler {
    static let shared = TransactionUIHandler()
    private lazy var panelHolder: TransactionHolderView = {
        let view = TransactionHolderView.createView()
        return view
    }()
    
    var window: UIWindow {
        return Router.coordinator.window
    }
    
    init() {
        addNotification()
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTransactionManagerChanged), name: .transactionManagerDidChanged, object: nil)
    }
    
    @objc private func onTransactionManagerChanged() {
        refreshPanelHolder()
    }
}

extension TransactionUIHandler {
    func showPanelHolder() {
        if panelHolder.superview == window {
            window.bringSubviewToFront(panelHolder)
            return
        }
        
        window.addSubview(panelHolder)
        panelHolder.show(inView: window)
    }
    
    func dismissPanelHolder() {
        if panelHolder.superview == nil {
            return
        }
        
        panelHolder.dismiss()
    }
    
    private func refreshPanelHolder() {
        if TransactionManager.shared.holders.isEmpty {
            dismissPanelHolder()
            return
        }
    }
}

extension TransactionUIHandler {
    
}
