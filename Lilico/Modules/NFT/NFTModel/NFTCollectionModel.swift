//
//  NFTCollectionModel.swift
//  Lilico
//
//  Created by cat on 2022/6/22.
//

import Foundation
import Flow


final class NFTCollectionConfig {
    static let share = NFTCollectionConfig()
    private init() {}

    var config: [NFTCollectionInfo] = []

    func reload() async {
        
        await fetchData()
    }

    func get(from address: String) async -> NFTCollectionInfo? {
        if config.isEmpty {
            await fetchData()
        }
        return config.first { $0.address.chooseBy(network: .mainnet) == address ||
            $0.address.chooseBy(network: .testnet) == address }
    }
}

extension NFTCollectionConfig {
    private func fetchData() async {
        do {
            let list: [NFTCollectionInfo] = try await FirebaseConfig.nftCollections.fetch()
            config.removeAll()
            
            config = list.filter{ item in
                if (LocalUserDefaults.shared.flowNetwork == .testnet) {
                    return item.secureCadenceCompatible.testnet
                }
                return item.secureCadenceCompatible.mainnet
            }
            
        } catch {
            fetchLocal()
        }
        // TODO:
    }

    private func fetchLocal() {
        // TODO: fetch json from local
    }
}
