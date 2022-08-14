//
//  NFTUIKitListView.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import SwiftUI

struct NFTUIKitListView: UIViewControllerRepresentable {
    @State var items: [CollectionItem]
    @State var gridItems: [NFTModel]
    @Binding var selectedCollectionIndex: Int
    @Binding var style: NFTTabScreen.ViewStyle
    
    var vm: NFTTabViewModel
    
    func makeUIViewController(context: Context) -> NFTUIKitListViewController {
        let vc = NFTUIKitListViewController()
        vc.vm = vm
        
        vc.styleDidChangedCallback = { newStyle in
            style = newStyle
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NFTUIKitListViewController, context: Context) {
        uiViewController.collectionItems = items
        uiViewController.selectedCollectionIndex = selectedCollectionIndex
        uiViewController.style = style
        uiViewController.gridItems = gridItems
        uiViewController.reloadViews()
    }
}
