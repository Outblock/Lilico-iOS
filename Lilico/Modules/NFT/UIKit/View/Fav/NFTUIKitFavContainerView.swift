//
//  NFTUIKitFavContainerView.swift
//  Lilico
//
//  Created by Selina on 17/8/2022.
//

import UIKit

class NFTUIKitFavContainerView: UIView {
    var itemSize: CGSize {
        let maxWidth = CGFloat(Router.coordinator.window.bounds.size.width - 18 * 2)
        let itemWidth = floor(264.0/339.0 * maxWidth)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    private lazy var collectionView: UICollectionView = {
        let viewLayout = CardsCollectionViewLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: viewLayout)
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        viewLayout.itemSize = itemSize
        return view
    }()
    
    static func calculateViewHeight() -> CGFloat {
        let scale = CGFloat(pow(0.95, -2.5))
        let maxWidth = CGFloat(Router.coordinator.window.bounds.size.width - 18 * 2)
        let itemWidth = floor(264.0/339.0 * maxWidth)
        
        return itemWidth * scale
    }
}
