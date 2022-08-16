//
//  NFTUIKitListViewController.swift
//  Lilico
//
//  Created by Selina on 11/8/2022.
//

import UIKit
import SnapKit
import SwiftUI

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
            make.height.equalTo(44)
        }
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
            
            self.reloadViews()
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        
        setupHeaderView()
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerContainerView.snp.bottom)
        }
        
        listStyleHandler.setup()
        gridStyleHandler.setup()
        
        reloadViews()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerContainerView)
        headerContainerView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
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
        case .grid:
            listStyleHandler.containerView.removeFromSuperview()
            
            if gridStyleHandler.containerView.superview != contentView {
                contentView.addSubview(gridStyleHandler.containerView)
                gridStyleHandler.containerView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                }
                
                gridStyleHandler.requestDataIfNeeded()
            }
        }
    }
}
