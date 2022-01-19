import Foundation
import SwiftUI

protocol NavigationOutputable {
    func using(coordinator: Any, input: Any) -> ViewPresentable
}

public protocol RouteType {}

public struct RootSwitch: RouteType {}

public struct Presentation: RouteType {
    let type: PresentationType
}

public struct Transition<T: NavigationCoordinatable, U: RouteType, Input, Output: ViewPresentable>: NavigationOutputable {
    let type: U
    let closure: (T) -> ((Input) -> Output)

    func using(coordinator: Any, input: Any) -> ViewPresentable {
        if Input.self == Void.self {
            return closure(coordinator as! T)(() as! Input)
        } else {
            return closure(coordinator as! T)(input as! Input)
        }
    }
}

@propertyWrapper public class NavigationRoute<T: NavigationCoordinatable, U: RouteType, Input, Output: ViewPresentable> {
    public var wrappedValue: Transition<T, U, Input, Output>

    init(standard: Transition<T, U, Input, Output>) {
        wrappedValue = standard
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Input == Void, Output == AnyView, U == Presentation {
    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput)), _ presentation: PresentationType) {
        self.init(standard: Transition(type: Presentation(type: presentation), closure: { coordinator in
            { _ in AnyView(wrappedValue(coordinator)()) }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Output == AnyView, U == Presentation {
    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> ((Input) -> ViewOutput)), _ presentation: PresentationType) {
        self.init(standard: Transition(type: Presentation(type: presentation), closure: { coordinator in
            { input in AnyView(wrappedValue(coordinator)(input)) }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Input == Void, Output: Coordinatable, U == Presentation {
    convenience init(wrappedValue: @escaping ((T) -> (() -> Output)), _ presentation: PresentationType) {
        self.init(standard: Transition(type: Presentation(type: presentation), closure: { coordinator in
            { _ in wrappedValue(coordinator)() }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Output: Coordinatable, U == Presentation {
    convenience init(wrappedValue: @escaping ((T) -> ((Input) -> Output)), _ presentation: PresentationType) {
        self.init(standard: Transition(type: Presentation(type: presentation), closure: { coordinator in
            { input in wrappedValue(coordinator)(input) }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Input == Void, Output == AnyView, U == RootSwitch {
    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> (() -> ViewOutput))) {
        self.init(standard: Transition(type: RootSwitch(), closure: { coordinator in
            { _ in AnyView(wrappedValue(coordinator)()) }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Output == AnyView, U == RootSwitch {
    convenience init<ViewOutput: View>(wrappedValue: @escaping ((T) -> ((Input) -> ViewOutput))) {
        self.init(standard: Transition(type: RootSwitch(), closure: { coordinator in
            { input in AnyView(wrappedValue(coordinator)(input)) }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Input == Void, Output: Coordinatable, U == RootSwitch {
    convenience init(wrappedValue: @escaping ((T) -> (() -> Output))) {
        self.init(standard: Transition(type: RootSwitch(), closure: { coordinator in
            { _ in wrappedValue(coordinator)() }
        }))
    }
}

public extension NavigationRoute where T: NavigationCoordinatable, Output: Coordinatable, U == RootSwitch {
    convenience init(wrappedValue: @escaping ((T) -> ((Input) -> Output))) {
        self.init(standard: Transition(type: RootSwitch(), closure: { coordinator in
            { input in wrappedValue(coordinator)(input) }
        }))
    }
}
