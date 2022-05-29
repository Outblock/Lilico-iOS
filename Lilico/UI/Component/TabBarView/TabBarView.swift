//
//  ContentView.swift
//  Test
//
//  Created by cat on 2022/5/23.
//

import SwiftUI

struct TabBarView<T: Hashable>: View {
    @State var current: T
    var pages: [TabBarPageModel<T>]
    
    var maxWidth: CGFloat
    @State private var offsetX: CGFloat
    @State private var currentIndex: Int
    
    init(current: T, pages: [TabBarPageModel<T>], maxWidth: CGFloat) {
        _current = State(initialValue: current)
        self.pages = pages
        self.maxWidth = maxWidth
        
        var selectIndex = 0
        for (index, page) in pages.enumerated() {
            if page.tag == current {
                selectIndex = index
            }
        }
        _currentIndex = State(initialValue: selectIndex)
        _offsetX = State(initialValue: maxWidth * CGFloat(selectIndex))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            tabView
            TabBar(pages: pages,
                   indicatorColor: getCurrentPageModel()?.color ?? .black,
                   offsetX: $offsetX,
                   selected: $current)
        }
    }
    
    var tabView: some View {
        TabView(selection: $current) {
            ForEach(0..<pages.count, id: \.self) { index in
                let pageModel = pages[index]
                pageModel.view()
                    .tag(pageModel.tag)
                    .background(
                        GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self, value: $0.frame(in: .named("frameLayer")))
                        }
                    )
                    .onPreferenceChange(ViewOffsetKey.self) {
                        offset(index: index, frame: $0)
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .background(.white)
        .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
        .ignoresSafeArea()
        .animation(.none, value: current)
        .onChange(of: current) { newValue in
            debugPrint("tab onChange \(current)")
            currentIndex = getCurrentPageIndex()
        }
        .coordinateSpace(name: "frameLayer")
    }
    
    private func offset(index: Int, frame: CGRect) {
        if currentIndex == index {
            let x = -frame.origin.x
            offsetX = CGFloat(index) * frame.size.width + x
        }
    }
    
    private func getCurrentPageModel() -> TabBarPageModel<T>? {
        for page in pages {
            if page.tag == current {
                return page
            }
        }
        
        return nil
    }
    
    private func getCurrentPageIndex() -> Int {
        for (index, page) in pages.enumerated() {
            if page.tag == current {
                return index
            }
        }
        return 0
    }
}

// MARK: - Helper

private struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGRect
    static var defaultValue = CGRect.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {}
}

struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    struct CornerRadiusShape: Shape {
        
        var radius = CGFloat.infinity
        var corners = UIRectCorner.allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}