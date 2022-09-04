//
//  NFTUIKitListViewController.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import SwiftUI
import Hero

class NFTUIKitListViewController: UIViewController {
    var style: NFTTabScreen.ViewStyle = .normal {
        didSet {
            self.reloadViews()
        }
    }
    
    var listStyleHandler: NFTUIKitListStyleHandler = NFTUIKitListStyleHandler()
    var gridStyleHandler: NFTUIKitGridStyleHandler = NFTUIKitGridStyleHandler()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        return view
    }()
    
    private lazy var headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        view.snp.makeConstraints { make in
            make.height.equalTo(Router.coordinator.window.safeAreaInsets.top + 44)
        }
        return view
    }()
    
    private lazy var headerBgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private lazy var headerContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        return view
    }()
    
    private lazy var segmentControl: NFTUIKitSegmentControl = {
        let view = NFTUIKitSegmentControl(names: ["seg_list".localized, "seg_grid".localized])
        view.callback = { [weak self] index in
            guard let self = self else {
                return
            }
            
            switch index {
            case 0:
                self.style = .normal
            case 1:
                self.style = .grid
            default:
                break
            }
            
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)
            feedbackGenerator.impactOccurred()
            
            self.reloadViews()
        }
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon-nft-add"), for: .normal)
        
        let bgColor = UIColor(Color.LL.Neutrals.neutrals3).withAlphaComponent(0.24)
        btn.setBackgroundImage(UIImage.image(withColor: bgColor), for: .normal)
        
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 16
        
        btn.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }
        
        btn.addTarget(self, action: #selector(onAddButtonClick), for: .touchUpInside)
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        self.hero.isEnabled = true
        setupHeaderView()
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerContainerView.snp.bottom)
        }
        
        listStyleHandler.setup()
        gridStyleHandler.setup()
        
        listStyleHandler.offsetCallback = { [weak self] offset in
            self?.offsetDidChanged(offset)
        }
        
        view.bringSubviewToFront(headerContainerView)
        
        reloadViews()
    }
    
    private func offsetDidChanged(_ offset: CGFloat) {
        let alpha = max(0, min(1, offset / 50.0))
        headerBgView.alpha = alpha
    }
    
    private func setupHeaderView() {
        view.addSubview(headerContainerView)
        headerContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(-Router.coordinator.window.safeAreaInsets.top)
        }
        
        headerContainerView.addSubview(headerBgView)
        headerBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerContainerView.addSubview(headerContentView)
        headerContentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        headerContentView.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalToSuperview()
        }
        
        headerContentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.right.equalTo(-18)
            make.centerY.equalToSuperview()
        }
        
        offsetDidChanged(0)
    }
    
    func reloadViews() {
        switch style {
        case .normal:
            gridStyleHandler.containerView.removeFromSuperview()
            
            if listStyleHandler.containerView.superview != contentView {
                contentView.addSubview(listStyleHandler.containerView)
                listStyleHandler.containerView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                
                listStyleHandler.requestDataIfNeeded()
            }
            
            offsetDidChanged(max(0.0, listStyleHandler.collectionView.contentOffset.y))
        case .grid:
            listStyleHandler.containerView.removeFromSuperview()
            
            if gridStyleHandler.containerView.superview != contentView {
                contentView.addSubview(gridStyleHandler.containerView)
                gridStyleHandler.containerView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                
                gridStyleHandler.requestDataIfNeeded()
            }
            
            offsetDidChanged(0)
        }
    }
    
    @objc private func onAddButtonClick() {
        Router.route(to: RouteMap.NFT.addCollection)
    }
}
