//
//  TransactionListHandler.swift
//  Lilico
//
//  Created by Selina on 9/9/2022.
//

import UIKit

private let Limit: Int = 30
private let CellHeight: CGFloat = 50
private let FooterHeight: CGFloat = 44

private let AllTransactionsListCacheKey = "AllTransactionListCacheKey"

class TransactionListHandler: TransactionListBaseHandler {
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.alwaysBounceVertical = true
        view.dataSource = self
        view.delegate = self
        view.register(FlowTransactionItemCell.self, forCellWithReuseIdentifier: "FlowTransactionItemCell")
        view.register(FlowTransactionViewMoreFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "FlowTransactionViewMoreFooter")
        
        view.setRefreshingAction { [weak self] in
            guard let self = self else {
                return
            }
            
            self.requestTransactions()
        }
        return view
    }()
    
    private var dataList: [FlowScanTransaction] = []
    var totalCount: Int = 0 {
        didSet {
            countChangeCallback?()
        }
    }
    
    private var isRequesting: Bool = false
    private var needShowLoadMoreView: Bool = false
    
    var countChangeCallback: (() -> ())?
    
    override init(contractId: String? = nil) {
        super.init(contractId: contractId)
        setup()
        loadCache()
    }
    
    private func setup() {
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.beginRefreshing()
    }
    
    private func loadCache() {
        if contractId != nil {
            // query by token, do not use cache
            return
        }
        
        Task {
            if let cacheList = try? await PageCache.cache.get(forKey: AllTransactionsListCacheKey, type: [FlowScanTransaction].self) {
                DispatchQueue.main.async {
                    self.dataList = cacheList
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension TransactionListHandler {
    func requestTransactions() {
        if isRequesting {
            return
        }
        
        isRequesting = true
        Task {
            do {
                let results = try await LilicoAPI.Account.fetchAccountTransfers()
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.requestSuccess(results.0, totalCount: results.1)
                }
            } catch {
                debugPrint("TransactionListHandler -> requestTransactions failed: \(error)")
                
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.collectionView.stopRefreshing()
                    HUD.error(title: "transaction_request_failed".localized)
                }
            }
        }
    }
    
    private func requestSuccess(_ list: [FlowScanTransaction], totalCount: Int) {
        PageCache.cache.set(value: list, forKey: AllTransactionsListCacheKey)
        
        var transactions = TransactionManager.shared.holders.map { $0.toFlowScanTransaction }
        transactions.append(contentsOf: list)
        
        collectionView.stopRefreshing()
        dataList = transactions
        collectionView.reloadData()
        
        LocalUserDefaults.shared.transactionCount = totalCount
        self.totalCount = totalCount + TransactionManager.shared.holders.count
        checkIfNeedShowLoadMoreView()
    }
    
    private func checkIfNeedShowLoadMoreView() {
        needShowLoadMoreView = totalCount > Limit
        collectionView.reloadData()
    }
}

extension TransactionListHandler: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataList[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowTransactionItemCell", for: indexPath) as! FlowTransactionItemCell
        cell.config(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: CellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if needShowLoadMoreView {
            return CGSize(width: 0, height: FooterHeight)
        }
        
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FlowTransactionViewMoreFooter", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataList[indexPath.item]
        if let hash = item.hash, let url = hash.toFlowScanTransactionDetailURL {
            UIApplication.shared.open(url)
        }
    }
}
