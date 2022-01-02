//
//  InnerCircleTabBar.swift
//  Lilico
//
//  Created by Hao Fu on 16/12/21.
//

import Foundation
import SwiftUI

struct InnerCircleTabBar: View {
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
            .frame(maxWidth: .infinity, maxHeight: hasHomeIndicator ? 60 : 49)
            .background(.ultraThinMaterial)
//            .background(
//                Circle()
//                    .fill(color)
//                    .offset(x: selectedX, y: -10)
//                    .frame(width: 88)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//            )
            .overlay(
                Rectangle()
                    .frame(width: 20, height: 5)
                    .cornerRadius(3)
                    .frame(width: 88)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .offset(x: selectedX)
//                    .blendMode(.overlay)
            )
            .padding(.bottom, hasHomeIndicator ? 32 : 0)
            .backgroundStyle(cornerRadius: hasHomeIndicator ? 34 : 0)
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
//                    Text(tab.name).font(.caption2)
//                        .frame(width: 88)
//                        .lineLimit(1)
                }
                .overlay(
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .global).minX - 22
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

struct InnerCircleTabBar_Previews: PreviewProvider {
    static var previews: some View {
        InnerCircleTabBar()
//        HomeView().colorScheme(.dark)
    }
}
