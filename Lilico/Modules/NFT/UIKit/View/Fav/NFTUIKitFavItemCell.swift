//
//  NFTUIKitFavItemCell.swift
//  Lilico
//
//  Created by Selina on 18/8/2022.
//

import UIKit
import SwiftUI
import SnapKit

private let Padding: CGFloat = 12

class NFTUIKitFavItemCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        contentView.backgroundColor = UIColor(Color.LL.background)
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Padding)
            make.right.equalToSuperview().offset(-Padding)
            make.top.equalToSuperview().offset(Padding)
            make.bottom.equalToSuperview().offset(-Padding)
        }
    }
    
    func config(_ item: NFTModel) {
        
    }
}
