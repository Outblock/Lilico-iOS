//
//  NFTUIKitTopSelectionHeaderView.swift
//  Lilico
//
//  Created by Selina on 19/8/2022.
//

import UIKit
import SwiftUI

class NFTUIKitTopSelectionHeaderView: UIView {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "icon-nft-top-selection")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = UIColor(Color.LL.frontColor)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .montserratBold(size: 22)
        label.textColor = UIColor(Color.LL.frontColor)
        label.text = "top_selection".localized
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("")
    }
    
    private func setup() {
        backgroundColor = .clear
        
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
