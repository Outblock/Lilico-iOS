//
//  NFTCoordinator.swift
//  Lilico
//
//  Created by cat on 2022/5/20.
//

import Foundation
import SwiftUI
import SwiftUIX

final class NFTCoordinator: NavigationCoordinatable, AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .nft
    }
    
    static func iconName() -> String {
        return "house.fill"
    }
    
    static func color() -> Color {
        return .LL.blue
    }
    
    var stack = NavigationStack(initial: \NFTCoordinator.start)
    
    @Root var start = makeStart
    @Root(.push) var detail = makeDetail

}

extension NFTCoordinator {
    @ViewBuilder func makeStart() -> some View {
        NFTTabScreen(viewModel: NFTTabViewModel().toAnyViewModel())
    }
    
    @ViewBuilder func makeDetail(model: NFTModel) -> some View {
        NFTDetailPage(nft: model)
    }
    
}
