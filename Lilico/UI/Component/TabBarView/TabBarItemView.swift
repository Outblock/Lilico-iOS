//
//  TabbarItem.swift
//  Test
//
//  Created by cat on 2022/5/25.
//

import SwiftUI

struct TabBarItemView<T: Hashable>: View {
    var pageModel: TabBarPageModel<T>
    @Binding var selected: T
    var action: () -> Void

    var body: some View {
        Button(action: {
            withAnimation(.spring()) { selected = pageModel.tag }
            action()
        }, label: {
            Image(systemName: pageModel.iconName)
                .renderingMode(.template)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(selected == pageModel.tag ? pageModel.color : Color.gray)
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contextMenu {
            if let m = pageModel.contextMenu {
                m()
            }
        }
    }
}
