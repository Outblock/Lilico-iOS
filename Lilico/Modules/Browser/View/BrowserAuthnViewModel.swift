//
//  BrowserAuthnViewModel.swift
//  Lilico
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI

extension BrowserAuthnViewModel {
    typealias Callback = (Bool) -> ()
}

class BrowserAuthnViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    private var callback: BrowserAuthnViewModel.Callback?
    
    init(title: String, url: String, logo: String?, callback: @escaping BrowserAuthnViewModel.Callback) {
        self.title = title
        self.urlString = url
        self.logo = logo
        self.callback = callback
    }
    
    func didChooseAction(_ result: Bool) {
        callback?(result)
        callback = nil
        Router.dismiss()
    }
    
    deinit {
        callback?(false)
    }
}
