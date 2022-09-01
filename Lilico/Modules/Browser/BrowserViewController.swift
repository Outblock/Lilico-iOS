//
//  BrowserViewController.swift
//  Lilico
//
//  Created by Selina on 1/9/2022.
//

import UIKit
import SwiftUI
import SnapKit
import WebKit

class BrowserViewController: UIViewController {
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var bgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var webViewConfig: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        return config
    }()
    
    private lazy var webView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: webViewConfig)
        view.backgroundColor = .orange
        return view
    }()
    
    private lazy var actionBarView: BrowserActionBarView = {
        let view = BrowserActionBarView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }
        
        contentView.layer.mask = bgMaskLayer
        
        contentView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(actionBarView)
        actionBarView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottomMargin).offset(-20)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadBgPaths()
    }
    
    private func reloadBgPaths() {
        bgMaskLayer.frame = contentView.bounds
        
        let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 24.0, height: 24.0))
        bgMaskLayer.path = path.cgPath
    }
}
