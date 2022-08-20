//
//  ExploreTabScreen.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import SwiftUI

extension ExploreTabScreen: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .explore
    }

    static func iconName() -> String {
        "Category"
    }

    static func color() -> SwiftUI.Color {
        return .LL.Secondary.violetDiscover
    }
}

struct ExploreTabScreen: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ExploreTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabScreen()
    }
}
