import Foundation
import SwiftUI

/// The NavigationViewCoordinator is used to represent a coordinator with a NavigationView
open class ViewWrapperCoordinator<T: Coordinatable, V: View>: Coordinatable {
    public func dismissChild<T: Coordinatable>(coordinator _: T, action: (() -> Void)?) {
        parent!.dismissChild(coordinator: self, action: action)
    }

    public weak var parent: ChildDismissable?
    public let child: T
    private let viewFactory: (AnyView) -> V

    public func view() -> AnyView {
        AnyView(
            ViewWrapperCoordinatorView(coordinator: self, viewFactory)
        )
    }

    public init(_ childCoordinator: T, _ view: @escaping (AnyView) -> V) {
        child = childCoordinator
        viewFactory = view
        child.parent = self
    }
}
