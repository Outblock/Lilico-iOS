//
//  NFTCollectionStateManager.swift
//  Lilico
//
//  Created by cat on 2022/6/22.
//

import Foundation
import Flow

final class NFTCollectionStateManager {
    
    static let share = NFTCollectionStateManager()
    
    private init() {
        
    }

    private var tokenStateList: [NftCollectionState] = []

    func fetch() async {
        let list = NFTCollectionConfig.share.config
        guard let address = WalletManager.shared.walletInfo?.primaryWalletModel?.getAddress,
                !address.isEmpty else {
            return
        }
        
        do {
            let isEnableList = try await FlowNetwork.checkCollectionEnable(address: Flow.Address(hex: address), list: list);
            guard isEnableList.count == list.count else {
                return
            }
            
            for (index, collection) in list.enumerated() {
                let isEnable = isEnableList[index]
                if let oldIndex = tokenStateList.firstIndex(where: { $0.address == collection.currentAddress()}) {
                    tokenStateList.remove(at: oldIndex)
                    tokenStateList.append(NftCollectionState(name: collection.name, address: collection.currentAddress(), isAdded: isEnable))
                }
            }
            
        }catch {
            print(error)
        }
    }
    func isTokenAdded(_ address: String) -> Bool {
        tokenStateList.first { $0.address == address }?.isAdded ?? false
    }
    

}

struct NftCollectionState {
    var name: String
    var address: String
    var isAdded: Bool
}
