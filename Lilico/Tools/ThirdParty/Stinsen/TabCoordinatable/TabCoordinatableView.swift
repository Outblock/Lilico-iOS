import Foundation
import SwiftUI

struct TabCoordinatableView<T: TabCoordinatable, U: View>: View {
    private var coordinator: T
    private let router: TabRouter<T>
    @ObservedObject var child: TabChild
    private var customize: (AnyView) -> U
    private var views: [AnyView]

    @State
    var offset: CGFloat = 0

    @State
    var scrollTo: CGFloat = -1

    var indicatorOffset: CGFloat {
        let progress = offset / screenWidth
        let maxWidth: CGFloat = (screenWidth - 40) / CGFloat(views.count)
        let value = progress * maxWidth + 20 + 10
//        + 10
//        + (progress * 2)

        print("offset -> \(offset), value -> \(value)")
        return value
    }

    var currentIndex: Int {
        let progress = round(offset / screenWidth)
        // For Saftey...
        let index = min(Int(progress), views.count - 1)
        return index
    }

    @State
    var color: Color = .secondary

    var tabColor: [Color] = [Color.LL.orange, Color.LL.yellow, Color.LL.blue, Color.purple]

    var body: some View {
        customize(
            AnyView(
                //                TabView(selection: $child.activeTab) {
//                    ForEach(Array(views.enumerated()), id: \.offset) { view in
//                        view
//                            .element
//                            .tabItem {
//                                coordinator.child.allItems[view.offset].tabItem(view.offset == child.activeTab)
//                            }
//                            .tag(view.offset)
//                    }
//                }
//                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                ZStack(alignment: .bottom) {
                    OffsetPageTabView(offset: $offset, scrollTo: $scrollTo) {
                        HStack(spacing: 0) {
                            EnumeratedForEach(views) { index, subview in
                                subview
                                    .frame(width: screenWidth)
                                    .tag(index)
                            }
                        }
                    }
                    .background(Color.LL.deepBg.edgesIgnoringSafeArea(.all))
                    .mask {
                        Rectangle()
                            .cornerRadius([.bottomLeading, .bottomTrailing], 20)
                            .offset(y: -50)
                        //                    .foregroundColor(.red)
                        //                    .cornerRadius([.bottomLeft, .bottomRight], 20)
                    }

                    HStack(spacing: 0) {
                        ForEach(Array(views.enumerated()), id: \.offset) { view in
                            Button {
                                withAnimation(.tabSelection) {
                                    scrollTo = screenWidth * CGFloat(view.offset)
                                }
                            } label: {
                                Image(systemName: currentIndex == view.offset ? "die.face.1.fill" : "die.face.1")
                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .background(Color.LL.deepBg)
                                    .padding(.vertical, 27)
                                    .foregroundColor(currentIndex == view.offset ? tabColor[currentIndex] : .secondary)
                                    .background(Color.LL.deepBg)
                            }.contextMenu(menuItems: {
                                Text("Action 1")
                                Text("Action 2")
                            })
                        }
                    }
                    .overlay(
                        Rectangle()
                            .frame(width: 28, height: 4)
                            .cornerRadius(3)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .offset(x: indicatorOffset)
                            .foregroundColor(tabColor[currentIndex])
                            .animation(.tabSelection, value: offset)
                    )
                    .padding(.horizontal, 20)
                    .frame(width: screenWidth, height: 30, alignment: .center)
                }
                .background {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.LL.background)
                        Rectangle()
                            .fill(Color.LL.deepBg)
                    }
                }.edgesIgnoringSafeArea(.top)
            )
        )
        .environmentObject(router)
    }

    init(paths _: [AnyKeyPath], coordinator: T, customize: @escaping (AnyView) -> U) {
        self.coordinator = coordinator

        router = TabRouter(coordinator: coordinator.routerStorable)
        RouterStore.shared.store(router: router)
        self.customize = customize
        child = coordinator.child

        if coordinator.child.allItems == nil {
            coordinator.setupAllTabs()
        }

        views = coordinator.child.allItems.map {
            $0.presentable.view()
        }
    }
}
