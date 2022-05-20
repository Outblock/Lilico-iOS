//
//  CommonBaseView.swift
//  Lilico
//
//  Created by Selina on 19/5/2022.
//

import SwiftUI

struct BaseView<Content>: View where Content: View {
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
        }
        .backgroundFill(.LL.Neutrals.background)
    }
}

struct BaseDivider: View {
    var body: some View {
        Divider().foregroundColor(.LL.Neutrals.background).padding(.horizontal, 8)
    }
}
