//
//  AddCollectionViewModel.swift
//  Lilico
//
//  Created by cat on 2022/6/26.
//

import Foundation
import Flow
import Combine

class AddCollectionViewModel: ObservableObject {
    private var cancelSets = Set<AnyCancellable>()
    
    @Published var searchQuery = ""
    @Published var isAddingCollection: Bool = false
    @Published var isConfirmSheetPresented: Bool = false

    var liveList: [NFTCollectionItem] {
        if searchQuery.isEmpty {
            return collectionList
        }
        var list: [NFTCollectionItem] = []
        list = collectionList.filter{ item in
            if item.collection.name.localizedCaseInsensitiveContains(searchQuery) {
                return true
            }
            if let des = item.collection.description, des.localizedCaseInsensitiveContains(searchQuery) {
                return true
            }
            return false
        }
        return list
        
    }
    
    private var collectionList: [NFTCollectionItem] = []
    
    init() {
        Task {
            await load()
        }
        
        NotificationCenter.default.publisher(for: .nftCollectionsDidChanged).sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            Task {
                await self.load()
            }
        }.store(in: &cancelSets)
    }
    
    func load() async {
        await NFTCollectionConfig.share.reload()
        await NFTCollectionStateManager.share.fetch()
        collectionList.removeAll { _ in true }
        collectionList = NFTCollectionConfig.share.config.filter({ col in
            !col.currentAddress().isEmpty
        })
        .map({ it in
            //TODO: handle status
            var status = NFTCollectionItem.ItemStatus.idle
            if(NFTCollectionStateManager.share.isTokenAdded(it.currentAddress())) {
                status = .own
            }
            //TODO: fail or pending
            return NFTCollectionItem(collection: it, status: status)
        })
        
        await MainActor.run {
            self.searchQuery = ""
        }
    }
}

extension AddCollectionViewModel {
    func hasTrending() -> Bool {
        //TODO:
        return false
    }
    
    func addCollectionAction(item: NFTCollectionItem) {
        if isAddingCollection {
            return
        }
        
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        if TransactionManager.shared.isCollectionEnabling(contractName: item.collection.contractName) {
            // TODO: show add collection bottom sheet
            return
        }
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isAddingCollection = false
                HUD.error(title: "add_collection_failed".localized)
            }
        }
        
        isAddingCollection = true
        
        Task {
            do {
                let transactionId = try await FlowNetwork.addCollection(at: Flow.Address(hex: address), collection: item.collection)
                
                guard let data = try? JSONEncoder().encode(item.collection) else {
                    failedBlock()
                    return
                }
                
                DispatchQueue.main.async {
                    self.isAddingCollection = false
                    self.isConfirmSheetPresented = false
                    
                    let holder = TransactionManager.TransactionHolder(id: transactionId, type: .addCollection, data: data)
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                debugPrint("AddCollectionViewModel -> addCollectionAction error: \(error)")
                failedBlock()
            }
        }
    }
}



struct NFTCollectionItem: Hashable {
    
    enum ItemStatus {
        case idle
        case own
        case pending
        case failed
    }
    
    var collection: NFTCollectionInfo
    var status: ItemStatus = .idle
    
    func processName() -> String {
        switch status {
            
        case .idle:
            return ""
        case .own:
            return ""
        case .pending:
            return "nft_collection_add_pending".localized
        case .failed:
            return "nft_collection_add_failed".localized
        }
    }
}
