//
//  NFTCollectionModel.swift
//  Lilico
//
//  Created by cat on 2022/6/22.
//

import Foundation

final class NFTCollectionConfig {
    static let share = NFTCollectionConfig()
    private init() {}

    var config: [NFTCollection] = []

    func reload() {
        Task {
            await fetchData()
        }
    }

    func get(from address: String) async -> NFTCollection? {
        if config.isEmpty {
            await fetchData()
        }
        return config.first { $0.address() == address }
    }
}

extension NFTCollectionConfig {
    private func fetchData() async {
        do {
            let list: [NFTCollection] = try await FirebaseConfig.nftCollections.fetch()
            config.removeAll()
            config.append(contentsOf: list)
        } catch {
            fetchLocal()
        }
        // TODO:
    }

    private func fetchLocal() {
        // TODO: fetch json from local
    }
}
