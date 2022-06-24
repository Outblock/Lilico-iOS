//
//  NFTListCache.swift
//  Lilico
//
//  Created by Selina on 15/6/2022.
//

import Combine
import Haneke
import SwiftUI

class NFTListCache {
    static let cache = NFTListCache()

    private var isRefreshing = false
    private var testOwner = "0x2b06c41f44a05656"
//    private var testOwner = "0x1e3c78c6d580273b"
    private var cancelSet = Set<AnyCancellable>()

    init() {
        UserManager.shared.$isLoggedIn.sink { _ in
            self.refresh()
        }.store(in: &cancelSet)
    }

    func refresh() {
        if !UserManager.shared.isLoggedIn || isRefreshing {
            return
        }

        debugPrint("NFTListCache -> start refreshing")

        isRefreshing = true

        let failed: (Error) -> Void = { error in
            debugPrint("NFTListCache -> refresh failed, error: \(error.localizedDescription)")

            DispatchQueue.main.async {
                self.isRefreshing = false
            }
        }

        Task {
            do {
                let nfts = try await handleNFTList()
                let data = try JSONEncoder().encode(nfts)
                Shared.dataCache.set(value: data, key: cacheKey)

                debugPrint("NFTListCache -> refresh success, total count: \(nfts.count)")
                DispatchQueue.main.async {
                    self.isRefreshing = false
                }
            } catch {
                failed(error)
            }
        }
    }

    func getNFTList() async throws -> [NFTResponse] {
        try await withCheckedThrowingContinuation { config in
            Shared.dataCache.fetch(key: cacheKey).onSuccess { data in
                do {
                    let nfts = try JSONDecoder().decode([NFTResponse].self, from: data)
                    config.resume(returning: nfts)
                } catch {
                    config.resume(throwing: error)
                }
            }.onFailure { error in
                config.resume(throwing: error ?? LLError.unknown)
            }
        }
    }
}

extension NFTListCache {
    private var cacheKey: String {
        let uid = UserManager.shared.getUid() ?? "0"
        return "\(uid)_nft_list_cache"
    }
}

extension NFTListCache {
    private func handleNFTList() async throws -> [NFTResponse] {
        var nfts: [NFTResponse] = []

        let limit = 25
        var offset = 0

        repeat {
            let result = try await fetchNFTList(from: offset, limit: limit)

            if result.count == 0 {
                break
            }

            nfts.append(contentsOf: result)
            offset += result.count

            if result.count < limit {
                break
            }

            #if DEBUG
                // just for debuging
                if nfts.count >= 20 {
                    break
                }
            #endif
        } while true

        return nfts
    }

    private func fetchNFTList(from offset: Int = 0, limit: Int = 25) async throws -> [NFTResponse] {
        #warning("Debug Only, need replace to real user address")
        let request = NFTRequest(address: testOwner, offset: offset, limit: limit)
        let response: Network.Response<NFTListResponse> = try await Network.requestWithRawModel(LilicoAPI.NFT.list(request))
        guard let nfts = response.data?.nfts else {
            return []
        }

        return nfts
    }
}
