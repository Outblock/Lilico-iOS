//
//  FlowTransactionViewMoreFooter.swift
//  Lilico
//
//  Created by Selina on 13/9/2022.
//

import UIKit
import SwiftUI

class FlowTransactionViewMoreFooter: UICollectionReusableView {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.LL.Neutrals.text
        label.font = .inter(size: 14)
        label.text = "view_more_transactions".localized
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: .arrowRight))
        imageView.tintColor = UIColor.LL.Neutrals.text
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func onTap() {
        guard let address = WalletManager.shared.getPrimaryWalletAddress(), let url = address.toFlowScanAccountDetailURL else {
            return
        }
        
        UIApplication.shared.open(url)
    }
}
