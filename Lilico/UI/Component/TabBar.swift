//
//  TabBar.swift
//  Lilico-lite
//
//  Created by Hao Fu on 27/11/21.
//

import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    var name: String
    var icon: String
    var color: Color
    var selection: Tab
}

var tabItems = [
    TabItem(name: "Wallet", icon: "house", color: Color.LL.orange, selection: .wallet),
    TabItem(name: "Expoler", icon: "magnifyingglass", color: Color.LL.yellow, selection: .explore),
    TabItem(name: "Profile", icon: "bell", color: Color.LL.blue, selection: .profile),
]

enum Tab: String, Equatable {
    case wallet
    case explore
    case profile

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct TabBar: View {
    @State var color: Color = .teal
    @State var selectedX: CGFloat = 0
    @State var x: [CGFloat] = [0, 0, 0, 0]

    @AppStorage("selectedTab") var selectedTab: Tab = .wallet

    var body: some View {
        GeometryReader { proxy in
            let hasHomeIndicator = proxy.safeAreaInsets.bottom > 0

            HStack {
                content
            }
            .padding(.bottom, hasHomeIndicator ? 16 : 0)
            .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 88 : 49)
//            .background(.bar)
            .background(Color.LL.background)
//            .background(
//                Circle()
//                    .fill(color)
//                    .offset(x: selectedX, y: -10)
//                    .frame(width: 88)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            )
            .overlay(
                Rectangle()
                    .frame(width: 28, height: 5)
                    .cornerRadius(3)
                    .frame(width: 88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: selectedX)
                    .foregroundColor(color)
//                    .blendMode(.)
            )
//            .backgroundStyle(cornerRadius: hasHomeIndicator ? 34 : 0)
            .cornerRadius(34)
            .modifier(OutlineOverlay(cornerRadius: 34))
            .frame(maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
//            .offset(y: model.showTab ? 0 : 200)
//            .accessibility(hidden: !model.showTab)
        }
    }

    var content: some View {
        ForEach(Array(tabItems.enumerated()), id: \.offset) { index, tab in
            if index == 0 { Spacer() }

            Button {
                selectedTab = tab.selection
                withAnimation(.tabSelection) {
                    selectedX = x[index]
                    color = tab.color
                }
            } label: {
                VStack(spacing: 0) {
                    Image(systemName: tab.icon)
                        .symbolVariant(.fill)
                        .font(.system(size: 17, weight: .bold))
                        .frame(width: 44, height: 29)
                    Text(tab.name).font(.caption2)
                        .frame(width: 88)
                        .lineLimit(1)
                }
                .overlay(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .global).minX
                        Color.clear
                            .preference(key: TabPreferenceKey.self, value: offset)
                            .onPreferenceChange(TabPreferenceKey.self) { value in
                                x[index] = value
                                if selectedTab == tab.selection {
                                    selectedX = x[index]
                                }
                            }
                    }
                )
            }
            .frame(width: 44)
            .foregroundColor(checkTab(tab.selection) ? color : .secondary)
//            .blendMode(checkTab(tab.selection) ? .overlay : .normal)
            Spacer()
        }
    }

    func checkTab(_ tab: Tab) -> Bool {
        selectedTab == tab
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
        HomeView().colorScheme(.dark)
    }
}

extension Animation {
    static let openCard = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let closeCard = Animation.spring(response: 0.6, dampingFraction: 0.9)
    static let flipCard = Animation.spring(response: 0.35, dampingFraction: 0.7)
    static let tabSelection = Animation.spring(response: 0.3, dampingFraction: 0.7)
}
