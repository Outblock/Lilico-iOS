//
//  NFTUIKitFavContainerView.swift
//  Lilico
//
//  Created by Selina on 17/8/2022.
//

import UIKit

class NFTUIKitFavContainerView: UIView {
    var items: [NFTModel] = []
    
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
        view.delegate = self
        view.dataSource = self
        view.register(NFTUIKitFavItemCell.self, forCellWithReuseIdentifier: "NFTUIKitFavItemCell")
        
        viewLayout.itemSize = itemSize
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    static func calculateViewHeight() -> CGFloat {
        let scale = 1.0
        let maxWidth = CGFloat(Router.coordinator.window.bounds.size.width - 18 * 2)
        let itemWidth = floor(264.0/339.0 * maxWidth)
        
        return itemWidth * scale
    }
}

extension NFTUIKitFavContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitFavItemCell", for: indexPath) as! NFTUIKitFavItemCell
        let item = items[indexPath.item]
        cell.config(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
