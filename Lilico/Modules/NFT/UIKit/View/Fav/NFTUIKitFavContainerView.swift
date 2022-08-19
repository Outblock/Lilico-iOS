//
//  NFTUIKitFavContainerView.swift
//  Lilico
//
//  Created by Selina on 17/8/2022.
//

import UIKit
import CollectionViewPagingLayout

class NFTUIKitFavContainerView: UIView {
    private lazy var headerView: NFTUIKitTopSelectionHeaderView = {
        let view = NFTUIKitTopSelectionHeaderView()
        return view
    }()
    
    private lazy var layout: CollectionViewPagingLayout = {
        let viewLayout = CollectionViewPagingLayout()
        viewLayout.numberOfVisibleItems = 8
        return viewLayout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(NFTUIKitFavItemCell.self, forCellWithReuseIdentifier: "NFTUIKitFavItemCell")
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(onDataSourceChanged), name: .nftFavDidChanged, object: nil)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    @objc private func onDataSourceChanged() {
        layout.invalidateLayoutInBatchUpdate(invalidateOffset: true)
        collectionView.reloadData()
    }
    
    private func setupView() {
        backgroundColor = .clear
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(32)
        }
        
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    static func calculateViewHeight() -> CGFloat {
        let maxWidth = CGFloat(Router.coordinator.window.bounds.size.width - 18 * 2)
        let itemWidth = floor(264.0/339.0 * maxWidth)
        
        return itemWidth + 32
    }
}

extension NFTUIKitFavContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return NFTUIKitCache.cache.favList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitFavItemCell", for: indexPath) as! NFTUIKitFavItemCell
        let item = NFTUIKitCache.cache.favList[indexPath.item]
        cell.config(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
