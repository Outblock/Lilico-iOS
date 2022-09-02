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
    private var observation: NSKeyValueObservation?
    private var actionBarIsHiddenFlag: Bool = false
    
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
        view.navigationDelegate = self
        return view
    }()
    
    private lazy var actionBarView: BrowserActionBarView = {
        let view = BrowserActionBarView()
        
        view.backBtn.addTarget(self, action: #selector(onBackBtnClick), for: .touchUpInside)
        view.homeBtn.addTarget(self, action: #selector(onHomeBtnClick), for: .touchUpInside)
        view.reloadBtn.addTarget(self, action: #selector(onReloadBtnClick), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onAddressBarClick))
        view.addressBarContainer.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        observation = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadBgPaths()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }
        
        contentView.layer.mask = bgMaskLayer
        
        setupWebView()
        setupActionBarView()
    }
    
    private func setupWebView() {
        contentView.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        webView.scrollView.delegate = self
    }
    
    private func setupActionBarView() {
        contentView.addSubview(actionBarView)
        actionBarView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.right.equalTo(-18)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide.snp.bottomMargin).offset(-20)
        }
    }
    
    private func setupObserver() {
        observation = webView.observe(\.estimatedProgress, options: .new, changeHandler: { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.reloadActionBarView()
            }
        })
    }
    
    private func reloadBgPaths() {
        bgMaskLayer.frame = contentView.bounds
        
        let path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 24.0, height: 24.0))
        bgMaskLayer.path = path.cgPath
    }
}

// MARK: - Load

extension BrowserViewController {
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - Action Bar

extension BrowserViewController {
    private func reloadActionBarView() {
        actionBarView.addressLabel.text = webView.title
        
        
        actionBarView.reloadBtn.isSelected = webView.isLoading
        
        actionBarView.progressView.isHidden = !webView.isLoading
        actionBarView.progressView.progress = webView.isLoading ? webView.estimatedProgress : 0
    }
    
    private func hideActionBarView() {
        if actionBarIsHiddenFlag {
            return
        }
        
        actionBarIsHiddenFlag = true
        
        UIView.animate(withDuration: 0.25) {
            let y = Router.coordinator.window.safeAreaInsets.bottom + 20 + BrowserActionBarViewHeight
            self.actionBarView.transform = CGAffineTransform(translationX: 0, y: y)
        }
    }
    
    private func showActionBarView() {
        if !actionBarIsHiddenFlag {
            return
        }
        
        actionBarIsHiddenFlag = false
        
        UIView.animate(withDuration: 0.25) {
            self.actionBarView.transform = .identity
        }
    }
    
    @objc private func onBackBtnClick() {
        if webView.canGoBack {
            webView.goBack()
            return
        }
        
        onHomeBtnClick()
    }
    
    @objc private func onHomeBtnClick() {
        Router.pop()
    }
    
    @objc private func onReloadBtnClick() {
        webView.reload()
    }
    
    @objc private func onAddressBarClick() {
        showSearchInputView()
    }
}

// MARK: - Search Recommend

extension BrowserViewController {
    private func showSearchInputView() {
        let inputVC = BrowserSearchInputViewController()
        inputVC.selectTextCallback = { [weak self] text in
            if let url = text.toSearchURL {
                self?.loadURL(url)
            }
        }
        self.show(childViewController: inputVC)
    }
}

// MARK: - Delegate

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        reloadActionBarView()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        reloadActionBarView()
    }
}

extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        
        if translation.y >= 0 {
            showActionBarView()
        } else {
            hideActionBarView()
        }
    }
}
