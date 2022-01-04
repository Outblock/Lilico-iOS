//
//  Keyboard.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
    extension View {
        func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

public extension View {
    func dismissKeyboardOnDrag() -> some View {
        gesture(DragGesture().onChanged { _ in self.dismissKeyboard() })
    }
}
