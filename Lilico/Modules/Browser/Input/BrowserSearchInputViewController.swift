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
    var selectTextCallback: ((String) -> ())?
    
    private var recommendArray: [RecommendItemModel] = []
    private var searchingText: String = ""
    
    private var timer: Timer?

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
        view.textDidReturnCallback = { [weak self] text in
            self?.selectTextCallback?(text)
            self?.close()
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
    
    public func setSearchText(text: String? = "") {
        self.searchingText = text ?? ""
        inputBar.textField.text = text
        inputBar.reloadView()
        if let str = text, !str.isEmpty {
            inputBar.textField.becomeFirstResponder()
            inputBar.textField.selectAll(self)
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
        close()
    }
    
    private func close() {
        if self.parent != nil {
            self.removeFromParentViewController()
        }
    }
}

extension BrowserSearchInputViewController {
    private func searchTextDidChanged(_ text: String) {
        clearCurrentRecommend()
        
        let trimString = text.trim()
        if trimString.isEmpty {
            return
        }
        
        searchingText = trimString
        startTimer()
    }
    
    static func makeUrlIfNeeded(urlString: String) -> String {
        var urlString = urlString

        if !urlString.hasPrefix("http://"), !urlString.hasPrefix("https://") {
            urlString = urlString.addHttpPrefix()
        }

        if urlString.validateUrl() {
            return urlString
        }

        if urlString.hasPrefix("http://") {
            urlString = String(urlString.dropFirst(7))
        }

        if urlString.hasPrefix("https://") {
            urlString = String(urlString.dropFirst(8))
        }

        let engine = "https://www.google.com/search?q="

        urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        urlString = "\(engine)\(urlString)"

        return urlString
    }
    
    private func doSearch() {
        debugPrint("doSearch")
        let currentText = self.searchingText
        
        Task {
            do {
                let result: [RecommendItemModel] = try await Network.requestWithRawModel(LilicoAPI.Browser.recommend(currentText))
                
                if self.searchingText != currentText {
                    // outdate result
                    return
                }
                
                DispatchQueue.main.async {
                    self.recommendArray = result
                    self.collectionView.reloadData()
                }
            } catch {
                if self.searchingText != currentText {
                    // outdate result
                    return
                }
                
                HUD.error(title: "browser_search_failed".localized)
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        let t = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(onTimer), userInfo: nil, repeats: false)
        RunLoop.main.add(t, forMode: .common)
        self.timer = t
    }
    
    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc private func onTimer() {
        doSearch()
    }
    
    private func clearCurrentRecommend() {
        self.searchingText = ""
        recommendArray.removeAll()
        collectionView.reloadData()
    }
}

extension BrowserSearchInputViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = recommendArray[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowserSearchItemCell", for: indexPath) as! BrowserSearchItemCell
        cell.config(model, inputText: searchingText)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = recommendArray[indexPath.item]
        selectTextCallback?(model.phrase)
        close()
    }
}
