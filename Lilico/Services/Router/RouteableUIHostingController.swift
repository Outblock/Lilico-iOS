//
//  RouteableUIHostingController.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import SwiftUI
import UIKit

typealias RouteableView = View & RouterContentDelegate

protocol RouterContentDelegate {
    /// UINavigationBar use this to smooth push animation
    var title: String { get }
    
    /// UINavigationController use this to smooth push animation
    var isNavigationBarHidden: Bool { get }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode { get }
    
    /// handle the back button action, default implementation is Router.pop()
    func backButtonAction()
}

extension RouterContentDelegate {
    var isNavigationBarHidden: Bool {
        return false
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .inline
    }
    
    func backButtonAction() {
        Router.pop()
    }
}

class RouteableUIHostingController<Content: RouteableView>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = rootView.title
        
        let backItem = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(onBackButtonAction))
        backItem.tintColor = UIColor(Color.LL.Button.color)
        navigationItem.leftBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(rootView.isNavigationBarHidden, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc private func onBackButtonAction() {
        rootView.backButtonAction()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
