//
//  CoinRateCache.swift
//  Lilico
//
//  Created by Selina on 23/6/2022.
//

import Combine
import Haneke
import SwiftUI

extension CoinRateCache {
    struct CoinRateModel: Codable {
        let updateTime: TimeInterval
        let symbol: String
        let summary: CryptoSummaryResponse
    }
}

private let CacheUpdateInverval = TimeInterval(30)

class CoinRateCache {
    static let cache = CoinRateCache()

    private var summarys: [CoinRateModel] = []

    private var isRefreshing = false

    private var cancelSets = Set<AnyCancellable>()

    init() {
        loadFromCache()

        NotificationCenter.default.publisher(for: .quoteMarketUpdated).sink { _ in
            DispatchQueue.main.async {
                self.refresh()
            }
        }.store(in: &cancelSets)

        WalletManager.shared.$activatedCoins.sink { _ in
            DispatchQueue.main.async {
                self.refresh()
            }
        }.store(in: &cancelSets)
    }

    func getSummary(for symbol: String) -> CryptoSummaryResponse? {
        return summarys.first { $0.symbol == symbol }?.summary
    }
}

extension CoinRateCache {
    private func loadFromCache() {
        if let cacheList = LocalUserDefaults.shared.coinSummarys {
            summarys.removeAll()
            summarys.append(contentsOf: cacheList)
        } else {
            summarys.removeAll()
        }
    }

    private func saveToCache() {
        LocalUserDefaults.shared.coinSummarys = summarys
    }

    private func refresh() {
        if isRefreshing {
            return
        }

        debugPrint("CoinRateCache -> start refreshing")
        isRefreshing = true
        Task {
            for coin in WalletManager.shared.activatedCoins {
                do {
                    try await fetchCoinRate(coin)
                } catch {
                    debugPrint("CoinRateCache -> fetchCoinRate:\(coin.symbol ?? "") failed: \(error)")
                }
            }

            isRefreshing = false
            debugPrint("CoinRateCache -> end refreshing")
        }
    }

    private func fetchCoinRate(_ coin: TokenModel) async throws {
        guard let symbol = coin.symbol else {
            return
        }

        if let old = summarys.first(where: { $0.symbol == symbol }) {
            let interval = abs(old.updateTime - Date().timeIntervalSince1970)
            if interval < CacheUpdateInverval {
                // still valid
                return
            }
        }

        let market = LocalUserDefaults.shared.market
        let coinPair = coin.getPricePair(market: market)
        if coinPair.isEmpty {
            return
        }

        let request = CryptoSummaryRequest(provider: market.rawValue, pair: coinPair)
        let response: CryptoSummaryResponse = try await Network.request(LilicoAPI.Crypto.summary(request))
        set(summary: response, forSymbol: symbol)
    }

    private func set(summary: CryptoSummaryResponse, forSymbol: String) {
        let model = CoinRateModel(updateTime: Date().timeIntervalSince1970, symbol: forSymbol, summary: summary)
        summarys.removeAll { m in
            m.symbol == model.symbol
        }

        summarys.append(model)
        saveToCache()
        NotificationCenter.default.post(name: .coinSummarysUpdated, object: nil)
    }
}
