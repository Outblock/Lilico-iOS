//
//  NFTUIKitListStyleHandler.swift
//  Lilico
//
//  Created by Selina on 15/8/2022.
//

import UIKit
import SnapKit
import SwiftUI

private let PinnedHeaderHeight: CGFloat = 80
private let CollecitonTitleViewHeight: CGFloat = 32

extension NFTUIKitListStyleHandler {
    enum Section: Int {
        case other
        case nft
    }
}

class NFTUIKitListStyleHandler: NSObject {
    var dataModel: NFTUIKitListNormalDataModel = NFTUIKitListNormalDataModel()
    private var isInitRequested: Bool = false
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        return view
    }()
    
    private lazy var collectionTitleView: NFTUIKitListTitleView = {
        let view = NFTUIKitListTitleView()
        view.switchButton.addTarget(self, action: #selector(onSwitchButtonClick), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var collectionHContainer: NFTUIKitCollectionHContainerView = {
        let view = NFTUIKitCollectionHContainerView()
        view.didSelectIndexCallback = { [weak self] newIndex in
            guard let self = self else {
                return
            }
            
            self.changeSelectCollectionIndexAction(newIndex)
        }
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
        view.register(NFTUIKitCollectionPinnedSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PinHeader")
        view.register(NFTUIKitCollectionPinnedSectionView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PinFooter")
        view.register(NFTUIKitItemCell.self, forCellWithReuseIdentifier: "NFTUIKitItemCell")
        view.register(NFTUIKitCollectionRegularItemCell.self, forCellWithReuseIdentifier: "NFTUIKitCollectionRegularItemCell")
        
        view.setRefreshingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            if self.collectionView.isLoading() {
                self.collectionView.stopRefreshing()
                return
            }
            
            self.refreshAction()
        }
        
        return view
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let viewLayout = UICollectionViewFlowLayout()
        viewLayout.scrollDirection = .vertical
        viewLayout.sectionHeadersPinToVisibleBounds = true
        return viewLayout
    }()
    
    func setup() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    private func reloadViews() {
        if dataModel.items.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
        
        collectionView.reloadData()
        collectionView.setNoMoreData(dataModel.selectedCollectionItem?.isEnd ?? true)
        
        setupLoadingActionIfNeeded()
    }
    
    private func setupLoadingActionIfNeeded() {
        if dataModel.isCollectionListStyle {
            collectionView.removeLoadingAction()
            return
        }
        
        if collectionView.mj_footer == nil {
            collectionView.setLoadingAction { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.loadMoreAction()
            }
        }
    }
}

extension NFTUIKitListStyleHandler {
    func requestDataIfNeeded() {
        if dataModel.items.isEmpty, !dataModel.isRequesting, !isInitRequested {
            collectionView.beginRefreshing()
        }
    }
    
    private func refreshAction() {
        hideErrorView()
        
        Task {
            do {
                try await dataModel.refreshCollectionAction()
                DispatchQueue.syncOnMain {
                    self.isInitRequested = true
                    self.collectionView.stopRefreshing()
                    
                    if !self.dataModel.items.isEmpty {
                        self.changeSelectCollectionIndexAction(0)
                    } else {
                        self.reloadViews()
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.isInitRequested = true
                    self.collectionView.stopRefreshing()
                    
                    if self.dataModel.items.isEmpty {
                        self.showErrorView()
                    } else {
                        HUD.error(title: "request_failed".localized)
                    }
                }
            }
        }
    }
    
    private func loadMoreAction() {
        guard let collectionItem = dataModel.selectedCollectionItem else {
            return
        }
        
        if collectionItem.isEnd {
            self.collectionView.stopLoading()
            self.collectionView.setNoMoreData(true)
            return
        }
        
        let snapshotIndex = self.dataModel.selectedIndex
        collectionItem.loadCallback = { [weak self] result in
            guard let self = self else {
                return
            }
            
            if snapshotIndex != self.dataModel.selectedIndex {
                // invalid callback
                return
            }
            
            if self.dataModel.isCollectionListStyle == true {
                // invalid callback
                return
            }
            
            self.collectionView.stopLoading()
            
            if result {
                self.reloadViews()
            } else {
                HUD.error(title: "request_failed".localized)
            }
        }
        
        collectionItem.load()
    }
}

extension NFTUIKitListStyleHandler {
    private func changeSelectCollectionIndexAction(_ newIndex: Int) {
        dataModel.isCollectionListStyle = false
        dataModel.selectedIndex = newIndex
        collectionHContainer.items = self.dataModel.items
        collectionHContainer.selectedIndex = self.dataModel.selectedIndex
        collectionHContainer.reloadViews()
        reloadViews()
        
        DispatchQueue.main.async {
            self.loadCurrentCollectionNFTsIfNeeded()
        }
    }
    
    private func loadCurrentCollectionNFTsIfNeeded() {
        if let item = dataModel.selectedCollectionItem, !dataModel.isCollectionListStyle, item.nfts.isEmpty, !item.isRequesting, !item.isEnd {
            collectionView.beginLoading()
        }
    }
    
    @objc private func onSwitchButtonClick() {
        collectionView.scrollToTop(animated: false)
        
        dataModel.isCollectionListStyle.toggle()
        reloadViews()
    }
}

extension NFTUIKitListStyleHandler {
    private func showLoadingView() {
        
    }
    
    private func hideLoadingView() {
        
    }
    
    private func showEmptyView() {
        
    }
    
    private func hideEmptyView() {
        
    }
    
    private func showErrorView() {
        
    }
    
    private func hideErrorView() {
        
    }
}

extension NFTUIKitListStyleHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Section.other.rawValue {
            return 0
        }
        
        if dataModel.isCollectionListStyle {
            return dataModel.items.count
        }
        
        return dataModel.selectedCollectionItem?.nfts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if dataModel.isCollectionListStyle {
            let collection = dataModel.items[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitCollectionRegularItemCell", for: indexPath) as! NFTUIKitCollectionRegularItemCell
            cell.config(collection)
            return cell
        }
        
        if let nftList = dataModel.selectedCollectionItem?.nfts, indexPath.item < nftList.count {
            let nft = nftList[indexPath.item]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NFTUIKitItemCell", for: indexPath) as! NFTUIKitItemCell
            cell.config(nft)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if dataModel.isCollectionListStyle {
            return NFTUIKitCollectionRegularItemCell.calculateSize()
        }
        
        return NFTUIKitItemCell.calculateSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == Section.other.rawValue {
            return .zero
        }
        
        if dataModel.isCollectionListStyle {
            return CGSize(width: 0, height: CollecitonTitleViewHeight)
        }
        
        return CGSize(width: 0, height: PinnedHeaderHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == Section.other.rawValue, !dataModel.isCollectionListStyle {
            return CGSize(width: 0, height: CollecitonTitleViewHeight)
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == Section.other.rawValue {
            if !dataModel.isCollectionListStyle, kind == UICollectionView.elementKindSectionFooter {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PinFooter", for: indexPath)
                if collectionTitleView.superview != footer {
                    collectionTitleView.removeFromSuperview()
                    footer.addSubview(collectionTitleView)
                    collectionTitleView.snp.makeConstraints { make in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                }
                
                return footer
            }
        }
        
        if kind != UICollectionView.elementKindSectionHeader {
            return UICollectionReusableView()
        }
        
        if dataModel.isCollectionListStyle {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PinHeader", for: indexPath)
            header.removeSubviews()
            collectionTitleView.removeFromSuperview()
            header.addSubview(collectionTitleView)
            collectionTitleView.snp.makeConstraints { make in
                make.left.right.top.bottom.equalToSuperview()
            }
            
            return header
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PinHeader", for: indexPath)
        header.removeSubviews()
        collectionHContainer.removeFromSuperview()
        header.addSubview(collectionHContainer)
        collectionHContainer.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if dataModel.isCollectionListStyle {
            return 12
        }
        
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if dataModel.isCollectionListStyle {
            return 12
        }
        
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == Section.other.rawValue {
            return .zero
        }
        
        return UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
    }
}