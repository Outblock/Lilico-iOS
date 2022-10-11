//
//  BrowserActionBarView.swift
//  Lilico
//
//  Created by Selina on 1/9/2022.
//

import UIKit
import SnapKit
import Hero

let BrowserActionBarViewHeight: CGFloat = 60
private let BtnWidth: CGFloat = 50
private let BtnHeight: CGFloat = 40
private let ProgressViewHeight: CGFloat = 4

class BrowserActionBarView: UIView {
    var bookmarkAction: ((Bool) -> ())?
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [backBtn, reloadBtn, addressBarContainer, menuBtn, homeBtn])
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon-btn-back"))
        btn.tintColor = .white
        btn.showsMenuAsPrimaryAction = true
        
        btn.snp.makeConstraints { make in
            make.width.equalTo(BtnWidth)
            make.height.equalTo(BtnHeight)
        }
        return btn
    }()
    
    lazy var homeBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon-btn-close"))
        btn.tintColor = .white
        
        btn.snp.makeConstraints { make in
            make.width.equalTo(BtnWidth)
            make.height.equalTo(BtnHeight)
        }
        return btn
    }()
    
    lazy var reloadBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon-btn-reload"), for: .normal)
        btn.setImage(UIImage(named: "icon-btn-reload-stop")?.withRenderingMode(.alwaysTemplate), for: .selected)
        btn.tintColor = .white
        
        btn.snp.makeConstraints { make in
            make.width.equalTo(BtnWidth)
            make.height.equalTo(BtnHeight)
        }
        
        return btn
    }()
    
    lazy var menuBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(named: "icon-btn-menu"))
        btn.tintColor = .white
        
        btn.snp.makeConstraints { make in
            make.width.equalTo(BtnWidth)
            make.height.equalTo(BtnHeight)
        }
        return btn
    }()
    
    lazy var addressBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.heroID = "addressBarContainer"
        return view
    }()
    
    private lazy var addressBarBgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.24).cgColor
        view.layer.cornerRadius = 12
        view.alpha = 0.8
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .interSemiBold(size: 14)
        label.text = ""
        return label
    }()
    
    lazy var progressView: BrowserProgressView = {
        let view = BrowserProgressView()
        view.progress = 0.5
        
        view.snp.makeConstraints { make in
            make.height.equalTo(ProgressViewHeight)
        }
        return view
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
        
        self.snp.makeConstraints { make in
            make.height.equalTo(BrowserActionBarViewHeight)
        }
        
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        setupAddressBarView()
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
            make.height.equalTo(BtnHeight)
        }
        
        contentView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupAddressBarView() {
        addressBarContainer.addSubview(addressBarBgView)
        addressBarBgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        addressBarContainer.addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
    }
}

extension BrowserActionBarView {
    func updateMenu(currentURL: URL?) {
        var children = [UIAction]()
        
        if let url = currentURL {
            let isBookmarked = DBManager.shared.webBookmarkIsExist(url: url.absoluteString)
            let bookmarkAction = UIAction(title: "browser_bookmark".localized, image: UIImage(systemName: isBookmarked ? .starFill : .star)) { [weak self] _ in
                guard let self = self else { return }
                self.bookmarkAction?(!isBookmarked)
            }
            
            children.append(bookmarkAction)
        }
        
        menuBtn.showsMenuAsPrimaryAction = true
        menuBtn.menu = UIMenu(title: "", children: children)
    }
}
