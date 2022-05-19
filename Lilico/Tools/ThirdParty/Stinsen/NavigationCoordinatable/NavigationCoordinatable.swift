import Combine
import Foundation
import SwiftUI

public protocol NavigationCoordinatable: Coordinatable {
    typealias Route = NavigationRoute
    typealias Root = NavigationRoute
    typealias Router = NavigationRouter<Self>
    associatedtype CustomizeViewType: View
    associatedtype RouterStoreType

    var routerStorable: RouterStoreType { get }

    var stack: NavigationStack<Self> { get }

    /**
     Implement this function if you wish to customize the view on all views and child coordinators, for instance, if you wish to change the `tintColor` or inject an `EnvironmentObject`.
     - Parameter view: The input view.
     - Returns: The modified view.
     */
    func customize(_ view: AnyView) -> CustomizeViewType

    func dismissCoordinator(_ action: (() -> Void)?)

    /**
     Clears the stack.
     */
    @discardableResult func popToRoot(_ action: (() -> Void)?) -> Self

    /**
     Appends a view to the navigation stack.

     - Parameter route: The route to append.
     - Parameter input: The parameters that are used to create the coordinator.
     */
    @discardableResult func route<Input, Output: View>(
        to route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) -> Self

    /**
     Appends a coordinator to the navigation stack.

     - Parameter route: The route to append.
     - Parameter input: The parameters that are used to create the coordinator.
     */
    @discardableResult func route<Input, Output: Coordinatable>(
        to route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) -> Output

    /**
     Appends a coordinator to the navigation stack.

     - Parameter route: The route to append.
     */
    @discardableResult func route<Output: Coordinatable>(
        to route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) -> Output

    /**
     Appends a view to the navigation stack.

     - Parameter route: The route to append.
     */
    @discardableResult func route<Output: View>(
        to route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) -> Self

    /**
     Searches the stack for the first route that matches the route. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) throws -> Output

    /**
     Searches the stack for the first route that matches the route. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) throws -> Self

    /**
     Searches the stack for the first route that matches the route. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.
     - Parameter input: The input that will be considered.
     - Parameter comparator: The function to use to determine if the inputs are equal

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) throws -> Output

    /**
     Searches the stack for the first route that matches the closure. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.
     - Parameter input: The input that will be considered.
     - Parameter comparator: The function to use to determine if the inputs are equal

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) throws -> Self

    /**
     Searches the stack for the first route that matches the route. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.
     - Parameter input: The input that will be considered. Since this function assumes input is Equatable, it will use the `==` function to determine equality.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) throws -> Output

    /**
     Searches the stack for the first route that matches the closure. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.
     - Parameter input: The input that will be considered. Since this function assumes input is Equatable, it will use the `==` function to determine equality.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) throws -> Self

    /**
     Searches the stack for the first route that matches the route. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>
    ) throws -> Output

    /**
     Searches the stack for the first route that matches the closure. If found, will remove
     everything after that route.

     - Parameter route: The route that will be focused.

     - Throws: `FocusError.routeNotFound`
               if the route was not found in the stack.
     */
    @discardableResult func focusFirst<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>
    ) throws -> Self

    @discardableResult func root<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Output

    @discardableResult func root<Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Self

    @discardableResult func root<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Output

    @discardableResult func root<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Self

    @discardableResult func root<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output

    @discardableResult func root<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Self

    @discardableResult func root<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Output

    @discardableResult func root<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Self

    func isRoot<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Bool

    func isRoot<Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Bool

    func isRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Bool

    func isRoot<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Bool

    func isRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Bool

    func isRoot<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Bool

    func isRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool

    func isRoot<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool

    @discardableResult func hasRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Output?

    @discardableResult func hasRoot<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Output?

    @discardableResult func hasRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Output?

    @discardableResult func hasRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output?
}

public extension NavigationCoordinatable {
    var routerStorable: Self {
        self
    }

    weak var parent: ChildDismissable? {
        get {
            return stack.parent
        } set {
            stack.parent = newValue
        }
    }

    func customize(_ view: AnyView) -> some View {
        return view
    }

    func dismissChild<T: Coordinatable>(coordinator: T, action: (() -> Void)?) {
        let value = stack.value.firstIndex { item in
            guard let presentable = item.presentable as? StringIdentifiable else {
                return false
            }

            return presentable.id == coordinator.id
        }!

        popTo(value - 1, action)
    }

    func dismissCoordinator(_ action: (() -> Void)?) {
        stack.parent!.dismissChild(coordinator: self, action: action)
    }

    internal func setupRoot() {
        let a = self[keyPath: stack.initial] as! NavigationOutputable
        let presentable = a.using(coordinator: self, input: stack.initialInput as Any)

        let item = NavigationRootItem(
            keyPath: stack.initial.hashValue,
            input: stack.initialInput,
            child: presentable
        )

        stack.root = NavigationRoot(item: item)
    }

    internal func appear(_ int: Int) {
        popTo(int, nil)
    }

    func popLast(_ action: (() -> Void)?) {
        popTo(stack.value.count - 2, action)
    }

    internal func popTo(_ int: Int, _ action: (() -> Void)?) {
        if let action = action {
            stack.dismissalAction[int] = action
        }

        guard int + 1 <= stack.value.count else {
            return
        }

        if int == -1 {
            stack.value = []
            stack.poppedTo.send(-1)
        } else if int >= 0 {
            stack.value = Array(stack.value.prefix(int + 1))
            stack.poppedTo.send(int)
        }
    }

    func view() -> AnyView {
        return AnyView(NavigationCoordinatableView(id: -1, coordinator: self))
    }

    func popToRoot(_ action: (() -> Void)? = nil) -> Self {
        popTo(-1, action)
        return self
    }

    @discardableResult func route<Input, Output: Coordinatable>(
        to route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) -> Output {
        let transition = self[keyPath: route]
        let output = transition.closure(self)(input)
        stack.value.append(
            NavigationStackItem(
                presentationType: transition.type.type,
                presentable: output,
                keyPath: route.hashValue,
                input: input
            )
        )
        output.parent = self
        return output
    }

    @discardableResult func route<Output: Coordinatable>(
        to route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) -> Output {
        let transition = self[keyPath: route]
        let output = transition.closure(self)(())
        stack.value.append(
            NavigationStackItem(
                presentationType: transition.type.type,
                presentable: output,
                keyPath: route.hashValue,
                input: nil
            )
        )
        output.parent = self
        return output
    }

    @discardableResult func route<Input, Output: View>(
        to route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) -> Self {
        let transition = self[keyPath: route]
        let output = transition.closure(self)(input)
        stack.value.append(
            NavigationStackItem(
                presentationType: transition.type.type,
                presentable: output,
                keyPath: route.hashValue,
                input: input
            )
        )
        return self
    }

    @discardableResult func route<Output: View>(
        to route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) -> Self {
        let transition = self[keyPath: route]
        let output = transition.closure(self)(())
        stack.value.append(
            NavigationStackItem(
                presentationType: transition.type.type,
                presentable: output,
                keyPath: route.hashValue,
                input: nil
            )
        )
        return self
    }

    @discardableResult private func _focusFirst<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: (value: Input, comparator: (Input, Input) -> Bool)?
    ) throws -> Output {
        guard let value = stack.value.enumerated().first(where: { item in
            guard item.element.keyPath == route.hashValue else {
                return false
            }

            guard let input = input else {
                return true
            }

            guard let compareTo = item.element.input else {
                fatalError()
            }

            return input.comparator(compareTo as! Input, input.value)
        }) else {
            throw FocusError.routeNotFound
        }

        popTo(value.offset, nil)

        return value.element.presentable as! Output
    }

    @discardableResult private func _focusFirst<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: (value: Input, comparator: (Input, Input) -> Bool)?
    ) throws -> Self {
        guard let value = stack.value.enumerated().first(where: { item in
            guard item.element.keyPath == route.hashValue else {
                return false
            }

            guard let input = input else {
                return true
            }

            guard let compareTo = item.element.input else {
                fatalError()
            }

            return input.comparator(compareTo as! Input, input.value)
        }) else {
            throw FocusError.routeNotFound
        }

        popTo(value.offset, nil)

        return self
    }

    @discardableResult func focusFirst<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) throws -> Output {
        try _focusFirst(route, nil)
    }

    @discardableResult func focusFirst<Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Void, Output>>
    ) throws -> Self {
        try _focusFirst(route, nil)
    }

    @discardableResult func focusFirst<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) throws -> Output {
        try _focusFirst(route, (value: input, comparator: comparator))
    }

    @discardableResult func focusFirst<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) throws -> Self {
        try _focusFirst(route, (value: input, comparator: comparator))
    }

    @discardableResult func focusFirst<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) throws -> Output {
        try _focusFirst(route, (value: input, comparator: { $0 == $1 }))
    }

    @discardableResult func focusFirst<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>,
        _ input: Input
    ) throws -> Self {
        try _focusFirst(route, (value: input, comparator: { $0 == $1 }))
    }

    @discardableResult func focusFirst<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>
    ) throws -> Output {
        try _focusFirst(route, nil)
    }

    @discardableResult func focusFirst<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, Presentation, Input, Output>>
    ) throws -> Self {
        try _focusFirst(route, nil)
    }

    @discardableResult private func _root<Output: Coordinatable, Input>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Output {
        if stack.root.item.keyPath == route.hashValue {
            if let inputItem = inputItem {
                if inputItem.comparator(inputItem.input, stack.root.item.input! as! Input) == true {
                    return stack.root.item.child as! Output
                }
            } else {
                return stack.root.item.child as! Output
            }
        }

        let output: Output

        if let input = inputItem?.input {
            output = self[keyPath: route].closure(self)(input)
        } else {
            output = self[keyPath: route].closure(self)(() as! Input)
        }

        stack.root.item = NavigationRootItem(
            keyPath: route.hashValue,
            input: inputItem?.input,
            child: output
        )

        return output
    }

    @discardableResult private func _root<Output: View, Input>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Self {
        if stack.root.item.keyPath == route.hashValue {
            if let inputItem = inputItem {
                if inputItem.comparator(inputItem.input, stack.root.item.input! as! Input) == true {
                    return self
                }
            } else {
                return self
            }
        }

        let output: Output

        if let input = inputItem?.input {
            output = self[keyPath: route].closure(self)(input)
        } else {
            output = self[keyPath: route].closure(self)(() as! Input)
        }

        stack.root.item = NavigationRootItem(
            keyPath: route.hashValue,
            input: inputItem?.input,
            child: AnyView(output)
        )

        return self
    }

    @discardableResult func root<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Output {
        _root(route, inputItem: nil)
    }

    @discardableResult func root<Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Self {
        _root(route, inputItem: nil)
    }

    @discardableResult func root<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Output {
        _root(route, inputItem: nil)
    }

    @discardableResult func root<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Self {
        _root(route, inputItem: nil)
    }

    @discardableResult func root<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output {
        _root(route, inputItem: (input, comparator))
    }

    @discardableResult func root<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Self {
        _root(route, inputItem: (input, comparator))
    }

    @discardableResult func root<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Output {
        _root(route, inputItem: (input, { $0 == $1 }))
    }

    @discardableResult func root<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Self {
        _root(route, inputItem: (input, { $0 == $1 }))
    }

    private func _isRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Bool {
        guard stack.root.item.keyPath == route.hashValue else {
            return false
        }

        guard let inputItem = inputItem else {
            return true
        }

        guard let compareTo = stack.root.item.input else {
            fatalError()
        }

        return inputItem.comparator(compareTo as! Input, inputItem.input)
    }

    private func _isRoot<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Bool {
        guard stack.root.item.keyPath == route.hashValue else {
            return false
        }

        guard let inputItem = inputItem else {
            return true
        }

        guard let compareTo = stack.root.item.input else {
            fatalError()
        }

        return inputItem.comparator(compareTo as! Input, inputItem.input)
    }

    private func _hasRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        inputItem: (input: Input, comparator: (Input, Input) -> Bool)?
    ) -> Output? {
        return _isRoot(route, inputItem: inputItem) ? (stack.root.item.child as! Output) : nil
    }

    @discardableResult func isRoot<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Bool {
        return _isRoot(route, inputItem: nil)
    }

    @discardableResult func isRoot<Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Bool {
        return _isRoot(route, inputItem: nil)
    }

    @discardableResult func isRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Bool {
        return _isRoot(route, inputItem: nil)
    }

    @discardableResult func isRoot<Input, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Bool {
        return _isRoot(route, inputItem: nil)
    }

    @discardableResult func isRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Bool {
        return _isRoot(route, inputItem: (input: input, comparator: { $0 == $1 }))
    }

    func isRoot<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Bool {
        return _isRoot(route, inputItem: (input: input, comparator: { $0 == $1 }))
    }

    func isRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool {
        return _isRoot(route, inputItem: (input: input, comparator: comparator))
    }

    func isRoot<Input: Equatable, Output: View>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Bool {
        return _isRoot(route, inputItem: (input: input, comparator: comparator))
    }

    @discardableResult func hasRoot<Input, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>
    ) -> Output? {
        return _hasRoot(route, inputItem: nil)
    }

    @discardableResult func hasRoot<Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Void, Output>>
    ) -> Output? {
        return _hasRoot(route, inputItem: nil)
    }

    @discardableResult func hasRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input
    ) -> Output? {
        return _hasRoot(route, inputItem: (input: input, comparator: { $0 == $1 }))
    }

    @discardableResult func hasRoot<Input: Equatable, Output: Coordinatable>(
        _ route: KeyPath<Self, Transition<Self, RootSwitch, Input, Output>>,
        _ input: Input,
        comparator: @escaping (Input, Input) -> Bool
    ) -> Output? {
        return _hasRoot(route, inputItem: (input: input, comparator: comparator))
    }
}
