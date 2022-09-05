//
//  WalletResponses.swift
//  Lilico
//
//  Created by Selina on 23/6/2022.
//

import Foundation

// MARK: - Coin Rate

extension CryptoSummaryResponse {
    struct Allowance: Codable {
        let cost: Double
        let remaining: Double
    }

    struct Result: Codable {
        let price: Price
    }

    struct Price: Codable {
        let last: Double
        let low: Double
        let high: Double
        let change: Change
    }

    struct Change: Codable {
        let absolute: Double
        let percentage: Double
    }
}

struct CryptoSummaryResponse: Codable {
    let allowance: CryptoSummaryResponse.Allowance
    let result: CryptoSummaryResponse.Result

    func getLastRate() -> Double {
        return result.price.last
    }

    func getChangePercentage() -> Double {
        return result.price.change.percentage
    }
}

// MARK: -

struct CryptoHistoryResponse: Codable {
    let allowance: CryptoSummaryResponse.Allowance
    let result: [String: [[Double]]]
    
    func parseMarketQuoteData(rangeType: TokenDetailView.ChartRangeType) -> [TokenDetailView.Quote] {
        guard let array = result["\(rangeType.frequency.rawValue)"] else {
            return []
        }
        
        var quotes = [TokenDetailView.Quote]()
        for l in array {
            let quote = TokenDetailView.Quote(closeTime: l[0], openPrice: l[1], highPrice: l[2], lowPrice: l[3], closePrice: l[4], volume: l[5], quoteVolume: l[6])
            quotes.append(quote)
        }
        
        return quotes
    }
}
