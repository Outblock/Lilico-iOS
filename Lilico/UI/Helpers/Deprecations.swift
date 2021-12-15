//
//  Deprecations.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 2/12/21.
//

import SwiftUI

// MARK: - V Web Link

@available(*, deprecated, renamed: "VWebLink")
public typealias VLink = VWebLink

@available(*, deprecated, renamed: "VWebLinkPreset")
public typealias VLinkPreset = VWebLinkPreset

@available(*, deprecated, renamed: "VWebLinkState")
public typealias VLinkState = VWebLinkState

// MARK: - V Toggle

extension VToggleState {
    @available(*, deprecated, renamed: "setNextState")
    mutating func nextState() { setNextState() }
}

// MARK: - V CheckBox

public extension VCheckBoxState {
    @available(*, deprecated, renamed: "indeterminate")
    static var intermediate: Self { indeterminate }

    @available(*, deprecated, renamed: "setNextState")
    mutating func nextState() { setNextState() }
}

// MARK: - V Radio Button

public extension VRadioButtonState {
    @available(*, deprecated, renamed: "setNextState")
    mutating func nextState() { setNextState() }
}

// MARK: - V List

@available(*, deprecated, renamed: "VList")
public typealias VSection = VList

@available(*, deprecated, renamed: "VListLayoutType")
public typealias VSectionLayoutType = VListLayoutType

@available(*, deprecated, renamed: "VListModel")
public typealias VSectionModel = VListModel

// MARK: - V Section List

@available(*, deprecated, renamed: "VSectionList")
public typealias VTable = VSectionList

@available(*, deprecated, renamed: "VSectionListLayoutType")
public typealias VTableLayoutType = VSectionListLayoutType

@available(*, deprecated, renamed: "VSectionListModel")
public typealias VTableModel = VSectionListModel

@available(*, deprecated, renamed: "VSectionListSectionViewModelable")
public typealias VTableSection = VSectionListSectionViewModelable

@available(*, deprecated, renamed: "VSectionListRowViewModelable")
public typealias VTableRow = VSectionListRowViewModelable

@available(*, deprecated, renamed: "VSectionListSectionViewModelable")
public typealias VSectionListSection = VSectionListSectionViewModelable

@available(*, deprecated, renamed: "VSectionListRowViewModelable")
public typealias VSectionListRow = VSectionListRowViewModelable

public extension VSectionListSectionViewModelable {
    @available(*, deprecated, renamed: "VSectionListRowViewModelable")
    typealias VSectionListRow = VSectionListRowViewModelable
}

@available(*, deprecated, message: "`VSectionListRowViewModelable` has been dropped. Use `Identifiable` instead.")
public typealias VSectionListRowViewModelable = Identifiable

// MARK: - V Accordion

public extension VAccordionState {
    @available(*, deprecated, renamed: "setNextState")
    mutating func nextState() { setNextState() }
}

// MARK: - Half Modal

public extension VHalfModalModel.Layout {
    @available(*, deprecated, renamed: "grabberSize")
    var resizeIndicatorSize: CGSize {
        get { grabberSize }
        set { grabberSize = newValue }
    }

    @available(*, deprecated, renamed: "grabberCornerRadius")
    var resizeIndicatorCornerRadius: CGFloat {
        get { grabberCornerRadius }
        set { grabberCornerRadius = newValue }
    }

    @available(*, deprecated, renamed: "grabberMargins")
    var resizeIndicatorMargins: VerticalMargins {
        get { grabberMargins }
        set { grabberMargins = newValue }
    }
}

public extension VHalfModalModel.Colors {
    @available(*, deprecated, renamed: "grabber")
    var resizeIndicator: Color {
        get { grabber }
        set { grabber = newValue }
    }
}

// MARK: - V Navigation View

public extension VNavigationViewModel.Colors {
    @available(*, deprecated, renamed: "bar")
    var background: Color {
        get { bar }
        set { bar = newValue }
    }
}

// MARK: - V Lazy Scroll View

@available(*, deprecated, renamed: "VLazyScrollView")
public typealias VLazyList = VLazyScrollView

@available(*, deprecated, renamed: "VLazyScrollViewType")
public typealias VLazyListType = VLazyScrollViewType

@available(*, deprecated, renamed: "VLazyScrollViewModelVertical")
public typealias VLazyListModelVertical = VLazyScrollViewModelVertical

@available(*, deprecated, renamed: "VLazyScrollViewModelHorizontal")
public typealias VLazyListModelHorizontal = VLazyScrollViewModelHorizontal

// MARK: - State Colors

public extension StateColors_OOID {
    @available(*, deprecated, renamed: "indeterminate")
    var intermediate: Color {
        get { indeterminate }
        set { indeterminate = newValue }
    }

    @available(*, deprecated, message: "Use `init(off:_, on:_, intermediate:_, disabled:_)` instead")
    init(off: Color, on: Color, intermediate: Color, disabled: Color) {
        self.off = off
        self.on = on
        indeterminate = intermediate
        self.disabled = disabled
    }
}

@available(*, deprecated, renamed: "StateColors_EFSEPD")
public typealias StateColors_EpFpSpEpD = StateColors_EFSEPD

public extension StateColors_EFSEPD {
    @available(*, deprecated, renamed: "pressedEnabled")
    var enabledPressed: Color {
        get { pressedEnabled }
        set { pressedEnabled = newValue }
    }

    @available(*, deprecated, renamed: "pressedFocused")
    var focusedPressed: Color {
        get { pressedFocused }
        set { pressedFocused = newValue }
    }

    @available(*, deprecated, renamed: "pressedSuccess")
    var successPressed: Color {
        get { pressedSuccess }
        set { pressedSuccess = newValue }
    }

    @available(*, deprecated, renamed: "pressedError")
    var errorPressed: Color {
        get { pressedError }
        set { pressedError = newValue }
    }

    @available(*, deprecated, message: "Use init with parameters of different labels")
    init(
        enabled: Color,
        enabledPressed: Color,
        focused: Color,
        focusedPressed: Color,
        success: Color,
        successPressed: Color,
        error: Color,
        errorPressed: Color,
        disabled: Color
    ) {
        self.enabled = enabled
        self.focused = focused
        self.success = success
        self.error = error
        pressedEnabled = enabledPressed
        pressedFocused = focusedPressed
        pressedSuccess = successPressed
        pressedError = errorPressed
        self.disabled = disabled
    }
}

@available(*, deprecated, renamed: "StateColorsAndOpacities_EFSEPD_PD")
public typealias StateColors_EpFpSpEpD_PD = StateColorsAndOpacities_EFSEPD_PD

public extension StateColorsAndOpacities_EFSEPD_PD {
    @available(*, deprecated, renamed: "pressedEnabled")
    var enabledPressed: Color {
        get { pressedEnabled }
        set { pressedEnabled = newValue }
    }

    @available(*, deprecated, renamed: "pressedFocused")
    var focusedPressed: Color {
        get { pressedFocused }
        set { pressedFocused = newValue }
    }

    @available(*, deprecated, renamed: "pressedSuccess")
    var successPressed: Color {
        get { pressedSuccess }
        set { pressedSuccess = newValue }
    }

    @available(*, deprecated, renamed: "pressedError")
    var errorPressed: Color {
        get { pressedError }
        set { pressedError = newValue }
    }

    @available(*, deprecated, message: "Use init with parameters of different labels")
    init(
        enabled: Color,
        enabledPressed: Color,
        focused: Color,
        focusedPressed: Color,
        success: Color,
        successPressed: Color,
        error: Color,
        errorPressed: Color,
        disabled: Color,
        pressedOpacity: CGFloat,
        disabledOpacity: CGFloat
    ) {
        self.enabled = enabled
        self.focused = focused
        self.success = success
        self.error = error
        pressedEnabled = enabledPressed
        pressedFocused = focusedPressed
        pressedSuccess = successPressed
        pressedError = errorPressed
        self.disabled = disabled
        self.pressedOpacity = pressedOpacity
        self.disabledOpacity = disabledOpacity
    }
}

// MARK: - Colors

public extension ColorBook {
    @available(*, deprecated, message: "Use SwiftUI's Color.clear")
    static let clear: Color = .clear
}

// MARK: - Basic Animations

public extension BasicAnimation {
    @available(*, deprecated, renamed: "AnimationCurve")
    typealias VAnimationCurve = AnimationCurve
}
