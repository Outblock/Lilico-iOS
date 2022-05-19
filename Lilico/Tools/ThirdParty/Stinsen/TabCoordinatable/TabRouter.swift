import Foundation
import SwiftUI

public class TabRouter<T>: Routable {
    public var coordinator: T {
        _coordinator.value as! T
    }

    private var _coordinator: WeakRef<AnyObject>

    public init(coordinator: T) {
        _coordinator = WeakRef(value: coordinator as AnyObject)
    }
}

public extension TabRouter where T: TabCoordinatable {
    /**
     Searches the tabbar for the first route that matches the route and makes it the active tab.

     - Parameter route: The route that will be focused.
     */
    @discardableResult func focusFirst<Output: Coordinatable>(
        _ route: KeyPath<T, TabA.Content<T, Output>>
    ) -> Output {
        coordinator.focusFirst(route)
    }

    /**
     Searches the tabbar for the first route that matches the route and makes it the active tab.

     - Parameter route: The route that will be focused.
     */
    @discardableResult func focusFirst<Output: View>(
        _ route: KeyPath<T, TabA.Content<T, Output>>
    ) -> T {
        coordinator.focusFirst(route)
    }
}
