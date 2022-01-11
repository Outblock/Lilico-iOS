//
//  TabCoordinator.swift
//  Lilico
//
//  Created by Hao Fu on 24/12/21.
//

import Stinsen
import SwiftUI

//final class TabBarCoordinator: NavigationCoordinatable {
//    var stack = NavigationStack(initial: \TabBarCoordinator.tab)
//
//    @Root var tab = makeTab
//
//    @ViewBuilder func makeTab() -> some View {
//        MainTabView()
//            .hideNavigationBar()
//    }
//}
//
final class NewTabBarCoordinator: TabCoordinatable {
    var child = TabChild(startingItems: [
        \NewTabBarCoordinator.home,
        \NewTabBarCoordinator.test,
    ])

    @Route(tabItem: makeHomeTab) var home = makeHome
    @Route(tabItem: makeTestIcon) var test = makeTest


    func makeHome() -> NavigationViewCoordinator<HomeCoordinator> {
        return NavigationViewCoordinator(HomeCoordinator())
    }

    func makeTest() ->NavigationViewCoordinator<BackupCoordinator> {
        return NavigationViewCoordinator(BackupCoordinator())
    }

    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }

    @ViewBuilder func makeTestIcon(isActive: Bool) -> some View {
        Image(systemName: "house" + (isActive ? ".fill" : ""))
        Text("Home")
    }

//    @Route
//    var tab = makeHomeTab

    func makeHomeTab() -> NavigationViewCoordinator<HomeCoordinator> {
        NavigationViewCoordinator(HomeCoordinator())
    }
}

//final class TabBarCoordinator: TabCoordinatable {
//    var child = TabChild(
//        startingItems: [
//            \TabBarCoordinator.home,
////            \AuthenticatedCoordinator.todos,
////            \AuthenticatedCoordinator.profile,
////            \AuthenticatedCoordinator.testbed
//        ]
//    )
//
//    func customize(_ view: AnyView) -> some View {
//        sharedView(view)
//    }
//
//    @ViewBuilder func sharedView(_ view: AnyView) -> some View {
//        ZStack(alignment: .bottom) {
//          view
////          CustomTabBarView() // <-- This is our custom tab bar
//
//            Text("123")
//        }
//    }
//
////    let todosStore: TodosStore
////    let user: User
//
//    @Route(tabItem: makeHomeTab) var home = makeHome
////    @Route(tabItem: makeTodosTab) var todos = makeTodos
////    @Route(tabItem: makeProfileTab) var profile = makeProfile
////    @Route(tabItem: makeTestbedTab) var testbed = makeTestbed
//
//    init() {
////        self.todosStore = TodosStore(user: user)
////        self.user = user
//    }
//
//    deinit {
//        print("Deinit AuthenticatedCoordinator")
//    }
//}
//
//extension TabBarCoordinator {
////    func makeTestbed() -> NavigationViewCoordinator<TestbedEnvironmentObjectCoordinator> {
////        return NavigationViewCoordinator(TestbedEnvironmentObjectCoordinator())
////    }
////
////    @ViewBuilder func makeTestbedTab(isActive: Bool) -> some View {
////        Image(systemName: "bed.double" + (isActive ? ".fill" : ""))
////        Text("Testbed")
////    }
//
//    func makeHome() -> NavigationViewCoordinator<HomeCoordinator> {
//        return NavigationViewCoordinator(HomeCoordinator())
//    }
//
//    @ViewBuilder func makeHomeTab(isActive: Bool) -> some View {
//        Image(systemName: "house" + (isActive ? ".fill" : ""))
//        Text("Home")
//    }
//
////    func makeTodos() -> NavigationViewCoordinator<TodosCoordinator> {
////        return NavigationViewCoordinator(TodosCoordinator(todosStore: todosStore))
////    }
////
////    @ViewBuilder func makeTodosTab(isActive: Bool) -> some View {
////        Image(systemName: "folder" + (isActive ? ".fill" : ""))
////        Text("Todos")
////    }
////
////    func makeProfile() -> NavigationViewCoordinator<ProfileCoordinator> {
////        return NavigationViewCoordinator(ProfileCoordinator(user: user))
////    }
////
////    @ViewBuilder func makeProfileTab(isActive: Bool) -> some View {
////        Image(systemName: "person.crop.circle" + (isActive ? ".fill" : ""))
////        Text("Profile")
////    }
//}
