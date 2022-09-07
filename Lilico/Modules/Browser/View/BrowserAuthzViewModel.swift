//
//  BrowserAuthzViewModel.swift
//  Lilico
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI

extension BrowserAuthzViewModel {
    typealias Callback = (Bool) -> ()
}

class BrowserAuthzViewModel: ObservableObject {
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var cadence: String
    @Published var isScriptShowing: Bool = false
    
    private var callback: BrowserAuthzViewModel.Callback?
    
    init(title: String, url: String, logo: String?, cadence: String, callback: @escaping BrowserAuthnViewModel.Callback) {
        self.title = title
        self.urlString = url
        self.logo = logo
        self.cadence = cadence
        self.callback = callback
    }
    
    func didChooseAction(_ result: Bool) {
        callback?(result)
        callback = nil
        Router.dismiss()
    }
    
    func changeScriptViewShowingAction(_ show: Bool) {
        withAnimation {
            self.isScriptShowing = show
        }
    }
    
    deinit {
        callback?(false)
    }
}
