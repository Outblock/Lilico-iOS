//
//  NFTCoordinator.swift
//  Lilico
//
//  Created by cat on 2022/5/20.
//

import Foundation
import SwiftUI
import SwiftUIX

final class NFTCoordinator: NavigationCoordinatable {
    
    var stack = NavigationStack(initial: \NFTCoordinator.start)
    
    var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action> = NFTTabViewModel().toAnyViewModel()
    
    @Root() var start = makeStart
    @Root(.push) var detail = makeDetail
    @Root(.push) var collection = makeCollection
}

extension NFTCoordinator {
    @ViewBuilder func makeStart() -> some View {
        NFTTabScreen(viewModel: self.viewModel)
            .hideNavigationBar()
    }
    
    @ViewBuilder func makeDetail(model: NFTModel) -> some View {
        NFTDetailPage(viewModel: self.viewModel, nft: model).hideNavigationBar()
    }
    
    @ViewBuilder func makeCollection(item: CollectionItem) -> some View {
        NFTCollectionListView(collection: item)
            .hideNavigationBar()
            .environmentObject(viewModel)
    }
}

extension NFTCoordinator: AppTabBarPageProtocol {
    static func tabTag() -> AppTabType {
        return .nft
    }
    
    static func iconName() -> String {
        return "house.fill"
    }
    
    static func color() -> Color {
        return .LL.blue
    }
}
