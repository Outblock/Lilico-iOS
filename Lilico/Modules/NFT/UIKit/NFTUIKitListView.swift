//
//  NFTUIKitListView.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import SwiftUI

struct NFTUIKitListView: UIViewControllerRepresentable {
    @State var items: [CollectionItem]
    @Binding var selectedCollectionIndex: Int
    
    func makeUIViewController(context: Context) -> NFTUIKitListViewController {
        return NFTUIKitListViewController()
    }
    
    func updateUIViewController(_ uiViewController: NFTUIKitListViewController, context: Context) {
        uiViewController.collectionItems = items
        uiViewController.selectedCollectionIndex = selectedCollectionIndex
        uiViewController.reloadViews()
    }
}
