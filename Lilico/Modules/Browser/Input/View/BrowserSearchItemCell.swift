//
//  BrowserSearchItemCell.swift
//  Lilico
//
//  Created by Selina on 2/9/2022.
//

import UIKit
import SnapKit

class BrowserSearchItemCell: UICollectionViewCell {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon-search-input"))
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .interMedium(size: 16)
        view.textColor = UIColor(hex: "#333333")
        view.text = "hahaha"
        view.snp.contentHuggingHorizontalPriority = 249
        view.snp.contentCompressionResistanceHorizontalPriority = 749
        return view
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "icon-search-arrow"))
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setup() {
        contentView.backgroundColor = .clear
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-30)
        }
    }
}
