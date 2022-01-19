import Foundation
import SwiftUI

/// The NavigationViewCoordinator is used to represent a coordinator with a NavigationView
public class NavigationViewCoordinator<T: Coordinatable>: ViewWrapperCoordinator<T, AnyView> {
    public init(_ childCoordinator: T) {
        super.init(childCoordinator) { view in
            #if os(macOS)
                AnyView(
                    NavigationView {
                        view
                    }
                )
            #else
                AnyView(
                    NavigationView {
                        view
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                )
            #endif
        }
    }

    @available(*, unavailable)
    override public init(_: T, _: @escaping (AnyView) -> AnyView) {
        fatalError("view cannot be customized")
    }
}
