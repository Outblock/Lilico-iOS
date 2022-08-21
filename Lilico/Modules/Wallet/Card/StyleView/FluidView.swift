//
//  WebView.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import SwiftUI
import WebKit
 
struct FluidView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.backgroundColor = UIColor(hex: "#121212")
        webview.isOpaque = false
        return webview
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let indexURL = Bundle.main.url(forResource: "index",
                                          withExtension: "html") {
            webView.loadFileURL(indexURL, allowingReadAccessTo: indexURL)
        }
        
    }
}
