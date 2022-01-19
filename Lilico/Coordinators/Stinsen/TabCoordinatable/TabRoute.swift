import Foundation
import SwiftUI

protocol Outputable {
    func using(coordinator: Any) -> ViewPresentable
    func tabItem(active: Bool, coordinator: Any) -> AnyView
}

public enum TabA {
    public struct Content<T: TabCoordinatable, Output: ViewPresentable>: Outputable {
        func tabItem(active: Bool, coordinator: Any) -> AnyView {
            return tabItem(coordinator as! T)(active)
        }

        func using(coordinator: Any) -> ViewPresentable {
            return closure(coordinator as! T)()
        }

        let closure: (T) -> (() -> Output)
        let tabItem: (T) -> ((Bool) -> AnyView)

        init<TabItem: View>(
            closure: @escaping ((T) -> (() -> Output)),
            tabItem: @escaping ((T) -> ((Bool) -> TabItem))
        ) {
            self.closure = closure
            self.tabItem = { coordinator in
                {
                    AnyView(tabItem(coordinator)($0))
                }
            }
        }
    }
}

@propertyWrapper public class TabRoute<T: TabCoordinatable, Output: ViewPresentable> {
    public var wrappedValue: TabA.Content<T, Output>

    fileprivate init(standard: TabA.Content<T, Output>) {
        wrappedValue = standard
    }
}

public extension TabRoute where T: TabCoordinatable, Output == AnyView {
    convenience init<ViewOutput: View, TabItem: View>(
        wrappedValue: @escaping ((T) -> (() -> ViewOutput)),
        tabItem: @escaping ((T) -> ((Bool) -> TabItem))
    ) {
        self.init(
            standard: TabA.Content(
                closure: { coordinator in { AnyView(wrappedValue(coordinator)()) }},
                tabItem: tabItem
            )
        )
    }
}

public extension TabRoute where T: TabCoordinatable, Output: Coordinatable {
    convenience init<TabItem: View>(
        wrappedValue: @escaping ((T) -> (() -> Output)),
        tabItem: @escaping ((T) -> ((Bool) -> TabItem))
    ) {
        self.init(
            standard: TabA.Content(
                closure: { coordinator in { wrappedValue(coordinator)() }},
                tabItem: tabItem
            )
        )
    }
}
