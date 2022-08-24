//
//  AddCollectionViewModel.swift
//  Lilico
//
//  Created by cat on 2022/6/26.
//

import Foundation
import Flow

class AddCollectionViewModel: ObservableObject {
    
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
        
        isAddingCollection = true
        
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        let successBlock = {
            DispatchQueue.main.async {
                self.isAddingCollection = false
                self.isConfirmSheetPresented = false
                HUD.success(title: "add_collection_success".localized)
                
                NotificationCenter.default.post(name: .nftCollectionsDidChanged, object: nil)
                
                Task {
                    await self.load()
                }
            }
        }
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isAddingCollection = false
                HUD.error(title: "add_collection_failed".localized)
            }
        }
        
        Task {
            do {
                let transactionId = try await FlowNetwork.addCollection(at: Flow.Address(hex: address), collection: item.collection)
                let result = try await transactionId.onceSealed()
                
                if result.isFailed {
                    debugPrint("AddCollectionViewModel -> addCollectionAction result failed errorMessage: \(result.errorMessage)")
                    failedBlock()
                    return
                }
                
                if result.isComplete {
                    successBlock()
                    return
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
