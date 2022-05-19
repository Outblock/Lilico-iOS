//
//  StateColors_EFSEPD.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 11/5/21.
//

import SwiftUI

// MARK: - Enabled, Focused, Success, Error, Pressed, Disabled

/// Color group containing `enabled`, `focused`, `success`, `error`, `pressed`, and `disabled` values.
public struct StateColors_EFSEPD: Equatable {
    // MARK: Properties

    /// Enabled color.
    public var enabled: Color

    /// Focused color.
    public var focused: Color

    /// Success color.
    public var success: Color

    /// Error color.
    public var error: Color

    /// Enabled pressed color.
    public var pressedEnabled: Color

    /// Focused pressed color.
    public var pressedFocused: Color

    /// Success pressed color.
    public var pressedSuccess: Color

    /// Error pressed color.
    public var pressedError: Color

    /// Disabled color.
    public var disabled: Color

    // MARK: Initializers

    /// Initializes group with values.
    public init(
        enabled: Color,
        focused: Color,
        success: Color,
        error: Color,
        pressedEnabled: Color,
        pressedFocused: Color,
        pressedSuccess: Color,
        pressedError: Color,
        disabled: Color
    ) {
        self.enabled = enabled
        self.focused = focused
        self.success = success
        self.error = error
        self.pressedEnabled = pressedEnabled
        self.pressedFocused = pressedFocused
        self.pressedSuccess = pressedSuccess
        self.pressedError = pressedError
        self.disabled = disabled
    }

    /// Initializes group with clear values.
    public init() {
        enabled = .clear
        focused = .clear
        success = .clear
        error = .clear
        pressedEnabled = .clear
        pressedFocused = .clear
        pressedSuccess = .clear
        pressedError = .clear
        disabled = .clear
    }

    /// Initializes group with clear values.
    public var clear: Self { .init() }
}
