//
//  BrowserSearchInputViewController.swift
//  Lilico
//
//  Created by Selina on 1/9/2022.
//

import UIKit
import SnapKit

private let CellHeight: CGFloat = 50

class BrowserSearchInputViewController: UIViewController {
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var inputBar: BrowserSearchInputBar = {
        let view = BrowserSearchInputBar()
        view.cancelBtn.addTarget(self, action: #selector(onCancelBtnClick), for: .touchUpInside)
        view.textDidChangedCallback = { [weak self] text in
            self?.searchTextDidChanged(text)
        }
        
        return view
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: Router.coordinator.window.bounds.size.width, height: CellHeight)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor(hex: "#F4F4F7")
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.delegate = self
        view.dataSource = self
        
        view.register(BrowserSearchItemCell.self, forCellWithReuseIdentifier: "BrowserSearchItemCell")
        return view
    }()
    
    private lazy var contentViewBgMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        view.backgroundColor = .black
        
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
        }
        
        contentView.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(contentView.keyboardLayoutGuide.snp.top)
        }
        
        contentView.layer.mask = contentViewBgMaskLayer
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(inputBar.snp.top)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadBgPaths()
    }
    
    private func reloadBgPaths() {
        contentViewBgMaskLayer.frame = contentView.bounds
        let cPath = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 24.0, height: 24.0))
        contentViewBgMaskLayer.path = cPath.cgPath
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !inputBar.textField.isFirstResponder {
            inputBar.textField.becomeFirstResponder()
        }
    }
}

extension BrowserSearchInputViewController {
    @objc private func onCancelBtnClick() {
        if self.parent != nil {
            self.removeFromParentViewController()
        }
    }
}

extension BrowserSearchInputViewController {
    private func searchTextDidChanged(_ text: String) {
        let trimString = text.trim()
        debugPrint("str = \(trimString)")
    }
}

extension BrowserSearchInputViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowserSearchItemCell", for: indexPath) as! BrowserSearchItemCell
        return cell
    }
}
