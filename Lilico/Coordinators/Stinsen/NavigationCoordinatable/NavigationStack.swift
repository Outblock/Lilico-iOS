import Combine
import Foundation
import SwiftUI

struct NavigationRootItem {
    let keyPath: Int
    let input: Any?
    let child: ViewPresentable
}

/// Wrapper around childCoordinators
/// Used so that you don't need to write @Published
public class NavigationRoot: ObservableObject {
    @Published var item: NavigationRootItem

    init(item: NavigationRootItem) {
        
        self.item = item
    }
}

/// Represents a stack of routes
public class NavigationStack<T: NavigationCoordinatable> {
    var dismissalAction: [Int: () -> Void] = [:]

    weak var parent: ChildDismissable?
    var poppedTo = PassthroughSubject<Int, Never>()
    let initial: PartialKeyPath<T>
    let initialInput: Any?
    var root: NavigationRoot!

    @Published var value: [NavigationStackItem]

    public init(initial: PartialKeyPath<T>, _ initialInput: Any? = nil) {
        value = []
        self.initial = initial
        self.initialInput = initialInput
        root = nil
    }
}

struct NavigationStackItem {
    let presentationType: PresentationType
    let presentable: ViewPresentable
    let keyPath: Int
    let input: Any?
}
