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
    var vm: NFTTabViewModel
    
    func makeUIViewController(context: Context) -> NFTUIKitListViewController {
        let vc = NFTUIKitListViewController()
        vc.vm = vm
        return vc
    }
    
    func updateUIViewController(_ uiViewController: NFTUIKitListViewController, context: Context) {
        uiViewController.collectionItems = items
        uiViewController.selectedCollectionIndex = selectedCollectionIndex
        uiViewController.reloadViews()
    }
}
