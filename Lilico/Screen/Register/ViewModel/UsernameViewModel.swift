//
//  UsernameViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation
import SwiftUI
import Stinsen

typealias VoidBlock = () -> Void
typealias BoolBlock = (Bool) -> Void

struct UsernameViewState {
//    var delegate: LL.TextField.Delegate
}

enum UsernameViewAction {
    case next
    case onEditingChanged(String)
    case onCommit
}

class UsernameViewModel: ViewModel {
    
    @Published
    private(set) var state: UsernameViewState
    
    func onEditingChanged(_ isEditing: Bool) {
        
    }

//    var onCommit: () -> Void = {
//    }
    
    func onCommit() {
        
    }
    
    init() {      
//        let delegate: LL.TextField.Delegate = .init { bool in
//            self.onEditingChanged(bool)
//        } onCommit: {
//            self.onCommit()
//        }
        state = .init()
    }
    
    
    
    func trigger(_ input: UsernameViewAction) {
        switch input {
        case .next:
            break
        case let .onEditingChanged(text):
            break
        case .onCommit:
            break
        }
    }
}
