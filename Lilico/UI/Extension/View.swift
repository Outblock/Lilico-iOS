//
//  View.swift
//  Lilico-lite
//
//  Created by Hao Fu on 27/11/21.
//

import SwiftUI
import UIKit

extension View {
    var screenBounds: CGRect {
        UIScreen.main.bounds
    }

    var screenWidth: CGFloat {
        screenBounds.width
    }

    var screenHeight: CGFloat {
        screenBounds.height
    }
}

public extension View {
    /// Applies modifier and transforms view if condition is met.
    @ViewBuilder func `if`<Content>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View
        where Content: View
    {
        switch condition {
        case false: self
        case true: transform(self)
        }
    }

    /// Applies modifier and transforms view if condition is met, or applies alternate modifier.
    @ViewBuilder func `if`<IfContent, ElseContent>(
        _ condition: Bool,
        ifTransform: (Self) -> IfContent,
        elseTransform: (Self) -> ElseContent
    ) -> some View
        where
        IfContent: View,
        ElseContent: View
    {
        switch condition {
        case false: ifTransform(self)
        case true: elseTransform(self)
        }
    }

    /// Applies modifier and transforms view if value is non-nil.
    @ViewBuilder func ifLet<Value, Content>(
        _ value: Value?,
        transform: (Self, Value) -> Content
    ) -> some View
        where Content: View
    {
        switch value {
        case let value?: transform(self, value)
        case nil: self
        }
    }

    /// Applies modifier and transforms view if value is non-nil, or applies alternate modifier.
    @ViewBuilder func ifLet<Value, IfContent, ElseContent>(
        _ value: Value?,
        ifTransform: (Self, Value) -> IfContent,
        elseTransform: (Self) -> ElseContent
    ) -> some View
        where
        IfContent: View,
        ElseContent: View
    {
        switch value {
        case let value?: ifTransform(self, value)
        case nil: elseTransform(self)
        }
    }
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
