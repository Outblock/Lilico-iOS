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
    var vm: NFTTabViewModel? {
        didSet {
            favContainerView.vm = vm
        }
    }
    var dataModel: NFTUIKitListNormalDataModel = NFTUIKitListNormalDataModel()
    private var isInitRequested: Bool = false
    
    var offsetCallback: ((CGFloat) -> ())?
    
    private lazy var emptyView: NFTUIKitListStyleHandler.EmptyView = {
        let view = NFTUIKitListStyleHandler.EmptyView()
        view.button.addTarget(self, action: #selector(onAddButtonClick), for: .touchUpInside)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        return view
    }()
    
    lazy var blurBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        return view
    }()
    
    private lazy var collectionTitleView: NFTUIKitListTitleView = {
        let view = NFTUIKitListTitleView()
        view.switchButton.addTarget(self, action: #selector(onSwitchButtonClick), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var collectionHContainer: NFTUIKitCollectionHContainerView = {
        let view = NFTUIKitCollectionHContainerView()
        view.items = dataModel.items
        view.didSelectIndexCallback = { [weak self] newIndex in
            guard let self = self else {
                return
            }
            
            self.changeSelectCollectionIndexAction(newIndex)
        }
        
        view.reloadViews()
        return view
    }()
    
    private lazy var favContainerView: NFTUIKitFavContainerView = {
        let view = NFTUIKitFavContainerView()
        return view
    }()
    
    lazy var collectionView: UICollectionView = {
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
        view.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        
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
        let offset = Router.coordinator.window.safeAreaInsets.top + 44.0
        
        containerView.addSubview(blurBgView)
        blurBgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-offset)
            make.height.equalTo(offset + NFTUIKitFavContainerView.calculateViewHeight())
        }
        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        containerView.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        emptyView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadBgView), name: .nftFavDidChanged, object: nil)
        reloadBgView()
    }
    
    private func reloadViews() {
        if dataModel.items.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
        
        reloadBgView()
        
        collectionView.reloadData()
        collectionView.setNoMoreData(dataModel.selectedCollectionItem?.isEnd ?? true)
        
        setupLoadingActionIfNeeded()
    }
    
    @objc private func reloadBgView() {
        blurBgView.isHidden = NFTUIKitCache.cache.favList.isEmpty
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
    
    @objc private func onAddButtonClick() {
        Router.route(to: RouteMap.NFT.addCollection)
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
        
        NFTUIKitCache.cache.requestFav()
        
        Task {
            do {
                try await dataModel.refreshCollectionAction()
                DispatchQueue.syncOnMain {
                    self.isInitRequested = true
                    
                    if !self.dataModel.items.isEmpty {
                        self.changeSelectCollectionIndexAction(0)
                    } else {
                        self.reloadViews()
                    }
                }
                
                DispatchQueue.main.async {
                    self.collectionView.stopRefreshing()
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
        self.emptyView.isHidden = false
    }
    
    private func hideEmptyView() {
        self.emptyView.isHidden = true
    }
    
    private func showErrorView() {
        
    }
    
    private func hideErrorView() {
        
    }
}

extension NFTUIKitListStyleHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        if offsetY <= 0 {
            offsetY = 0
        }
        
        blurBgView.transform = CGAffineTransform.init(translationX: 0, y: -offsetY)
        
        offsetCallback?(offsetY)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == Section.other.rawValue {
            return NFTUIKitCache.cache.favList.isEmpty ? 0 : 1
        }
        
        if dataModel.isCollectionListStyle {
            return dataModel.items.count
        }
        
        return dataModel.selectedCollectionItem?.nfts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == Section.other.rawValue {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
            cell.contentView.backgroundColor = .clear
            
            if favContainerView.superview != cell.contentView {
                cell.contentView.addSubview(favContainerView)
                favContainerView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
            }
            
            return cell
        }
        
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
        if indexPath.section == Section.other.rawValue {
            return CGSize(width: collectionView.bounds.size.width, height: NFTUIKitFavContainerView.calculateViewHeight())
        }
        
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
        if section == Section.other.rawValue, !dataModel.isCollectionListStyle, !dataModel.items.isEmpty {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section != Section.nft.rawValue {
            return
        }
        
        guard let vm = vm else {
            return
        }
        
        if !dataModel.isCollectionListStyle, let nftList = dataModel.selectedCollectionItem?.nfts, indexPath.item < nftList.count {
            let nft = nftList[indexPath.item]
            Router.route(to: RouteMap.NFT.detail(vm, nft))
            return
        }
        
        if dataModel.isCollectionListStyle, indexPath.item < dataModel.items.count {
            let collectionItem = dataModel.items[indexPath.item]
            Router.route(to: RouteMap.NFT.collection(vm, collectionItem))
        }
    }
}

extension NFTUIKitListStyleHandler {
    class EmptyView: UIView {
        private lazy var bgImageView: UIImageView = {
            let view = UIImageView(image: UIImage(named: "nft_empty_bg"))
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            return view
        }()
        
        private lazy var iconImageView: UIImageView = {
            let view = UIImageView(image: UIImage(named: "icon-empty"))
            return view
        }()
        
        private lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.font = .montserratBold(size: 16)
            view.textColor = UIColor(Color.LL.Neutrals.neutrals3)
            view.text = "nft_empty".localized
            return view
        }()
        
        private lazy var descLabel: UILabel = {
            let view = UILabel()
            view.font = .inter(size: 14)
            view.textColor = UIColor(Color.LL.Neutrals.neutrals8)
            view.text = "nft_empty_discovery".localized
            return view
        }()
        
        lazy var button: UIButton = {
            let btn = UIButton(type: .custom)
            let bg = UIImage.image(withColor: UIColor(Color.LL.Secondary.mango4).withAlphaComponent(0.08))
            btn.setBackgroundImage(bg, for: .normal)
            
            btn.setTitle("get_new_nft".localized, for: .normal)
            btn.setTitleColor(UIColor(Color.LL.Secondary.mangoNFT), for: .normal)
            btn.titleLabel?.font = .interSemiBold(size: 14)
            
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 43, bottom: 10, right: 43)
            
            btn.clipsToBounds = true
            btn.layer.cornerRadius = 12
            
            return btn
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("")
        }
        
        private func setup() {
            addSubview(bgImageView)
            bgImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            addSubview(iconImageView)
            iconImageView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-70)
            }
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(iconImageView.snp.bottom).offset(16)
            }
            
            addSubview(descLabel)
            descLabel.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
            }
            
            addSubview(button)
            button.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(descLabel.snp.bottom).offset(36)
            }
        }
    }
}
