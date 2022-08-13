//
//  NFTUIKitListViewController.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import SwiftUI

private let PinnedHeaderHeight: CGFloat = 56

class NFTUIKitListViewController: UIViewController {
    var collectionItems: [CollectionItem] = []
    var style: NFTTabScreen.ViewStyle = .normal
    var selectedCollectionIndex: Int = 0
    var vm: NFTTabViewModel?
    
    private lazy var collectionTitleView: NFTUIKitListTitleView = {
        let view = NFTUIKitListTitleView()
        view.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
        
        view.switchButton.addTarget(self, action: #selector(onSwitchButtonClick), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var collectionHContainer: NFTUIKitCollectionHContainerView = {
        let view = NFTUIKitCollectionHContainerView()
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInsetAdjustmentBehavior = .never
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.register(NFTUIKitCollectionPinnedSectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "NFTUIKitCollectionPinnedSectionHeader")
        view.register(NFTUIKitItemCell.self, forCellWithReuseIdentifier: "NFTUIKitItemCell")
        view.register(NFTUIKitCollectionRegularItemCell.self, forCellWithReuseIdentifier: "NFTUIKitCollectionRegularItemCell")
        
        view.setRefreshingAction { [weak self] in
            self?.vm?.refreshCollectionAction()
        }
        
        return view
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .vertical
        viewLayout.sectionHeadersPinToVisibleBounds = true
        return viewLayout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        
        view.addSubview(collectionTitleView)
        collectionTitleView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(collectionTitleView.snp.bottom)
        }
    }
    
    func reloadViews() {
        collectionHContainer.items = collectionItems
        collectionHContainer.selectedIndex = selectedCollectionIndex
        collectionHContainer.reloadViews()
        
        collectionView.reloadData()
        collectionView.stopRefreshing()
        collectionView.stopLoading()
        
        setupLoadingActionIfNeeded()
        
        removeAllLoadCallback()
        loadNFTsIfNeeded()
    }
}

extension NFTUIKitListViewController {
    private func setupLoadingActionIfNeeded() {
        switch style {
        case .normal, .grid:
            if collectionView.mj_footer == nil {
                collectionView.setLoadingAction { [weak self] in
                    self?.loadMoreAction()
                }
            }
        case .collectionList:
            collectionView.removeLoadingAction()
        }
    }
    
    private func currentSelectedCollectionItem() -> CollectionItem? {
        if selectedCollectionIndex > collectionItems.count {
            return nil
        }
        
        return collectionItems[selectedCollectionIndex]
    }
    
    private func removeAllLoadCallback() {
        for item in collectionItems {
            item.loadCallback = nil
        }
    }
    
    private func loadNFTsIfNeeded() {
        switch style {
        case .normal:
            if let collectionItem = currentSelectedCollectionItem(), !collectionItem.isEnd, collectionItem.nfts.isEmpty {
                loadMoreAction()
            }
        default:
            break
        }
    }
    
    private func loadMoreAction() {
        guard let collectionItem = currentSelectedCollectionItem() else {
            return
        }
        
        let snapshotIndex = self.selectedCollectionIndex
        collectionItem.loadCallback = { [weak self] result in
            if snapshotIndex != self?.selectedCollectionIndex {
                // invalid callback
                return
            }
            
            if self?.style != .normal {
                // invalid callback
                return
            }
            
            self?.collectionView.stopLoading()
            
            if result {
                self?.collectionView.reloadData()
                self?.collectionView.setNoMoreData(self?.currentSelectedCollectionItem()?.isEnd ?? true)
            }
        }
        
        collectionItem.load()
    }
    
    @objc private func onSwitchButtonClick() {
        collectionView.scrollToTop(animated: false)
        
        if style == .collectionList {
            style = .normal
        } else {
            style = .collectionList
        }
        
        reloadViews()
    }
}

extension NFTUIKitListViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch style {
        case .normal:
            return currentSelectedCollectionItem()?.nfts.count ?? 0
        case .collectionList:
            return collectionItems.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch style {
        case .normal:
            if let nftList = currentSelectedCollectionItem()?.nfts, indexPath.item < nftList.count {
                let nft = nftList[indexPath.item]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitItemCell", for: indexPath) as! NFTUIKitItemCell
                cell.config(nft)
                return cell
            } else {
                return UICollectionViewCell()
            }
        case .collectionList:
            let collection = collectionItems[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitCollectionRegularItemCell", for: indexPath) as! NFTUIKitCollectionRegularItemCell
            cell.config(collection)
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch style {
        case .normal:
            return NFTUIKitItemCell.calculateSize()
        case .collectionList:
            return NFTUIKitCollectionRegularItemCell.calculateSize()
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch style {
        case .normal:
            return CGSize(width: 0, height: PinnedHeaderHeight)
        case .collectionList:
            return .zero
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch style {
        case .normal:
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NFTUIKitCollectionPinnedSectionHeader", for: indexPath)
                if collectionHContainer.superview != header {
                    collectionHContainer.removeFromSuperview()
                    header.addSubview(collectionHContainer)
                    collectionHContainer.snp.makeConstraints { make in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                }
                
                return header
            } else {
                return UICollectionReusableView()
            }
        case .collectionList:
            return UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch style {
        case .normal:
            return 18
        case .collectionList:
            return 12
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        switch style {
        case .normal:
            return 18
        case .collectionList:
            return 12
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
}
