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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(Color.LL.Neutrals.background)
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        listStyleHandler.setup()
        gridStyleHandler.setup()
        
        reloadViews()
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
