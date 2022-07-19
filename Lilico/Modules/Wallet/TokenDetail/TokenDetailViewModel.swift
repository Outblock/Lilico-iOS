//
//  TokenDetailViewModel.swift
//  Lilico
//
//  Created by Selina on 1/7/2022.
//

import SwiftUI
import Combine
import SwiftUICharts
import Stinsen

extension TokenDetailView {
    struct Quote: Codable {
        let closeTime: Double
        let openPrice: Double
        let highPrice: Double
        let lowPrice: Double
        let closePrice: Double
        let volume: Double
        let quoteVolume: Double
        
        var generateChartPoint: LineChartDataPoint {
            let date = Date(timeIntervalSince1970: closeTime)
            return LineChartDataPoint(value: closePrice, description: date.ymdString, date: date)
        }
    }

    enum PeriodFrequency: Int {
        case halfHour = 1800
        case oneHour = 3600
        case oneDay = 86400
        case threeDay = 259200
        case oneWeek = 604800
    }
    
    enum ChartRangeType: CaseIterable {
        case d1
        case w1
        case m1
        case m3
        case y1
        case all
        
        var title: String {
            switch self {
            case .d1:
                return "1D"
            case .w1:
                return "1W"
            case .m1:
                return "1M"
            case .m3:
                return "3M"
            case .y1:
                return "1Y"
            case .all:
                return "ALL"
            }
        }
        
        var frequency: TokenDetailView.PeriodFrequency {
            switch self {
            case .d1:
                return .halfHour
            case .w1:
                return .oneHour
            case .m1, .m3:
                return .oneDay
            case .y1:
                return .threeDay
            case .all:
                return .oneWeek
            }
        }
        
        var after: String {
            let oneDayInterval: TimeInterval = 24 * 60 * 60
            switch self {
            case .d1:
                return String(format: "%.0lf", Date(timeIntervalSinceNow: -oneDayInterval).timeIntervalSince1970)
            case .w1:
                return String(format: "%.0lf", Date(timeIntervalSinceNow: -oneDayInterval * 7).timeIntervalSince1970)
            case .m1:
                return String(format: "%.0lf", Date(timeIntervalSinceNow: -oneDayInterval * 30).timeIntervalSince1970)
            case .m3:
                return String(format: "%.0lf", Date(timeIntervalSinceNow: -oneDayInterval * 90).timeIntervalSince1970)
            case .y1:
                return String(format: "%.0lf", Date(timeIntervalSinceNow: -oneDayInterval * 365).timeIntervalSince1970)
            case .all:
                return ""
            }
        }
    }
}

class TokenDetailViewModel: ObservableObject {
    @RouterObject var router: WalletCoordinator.Router?
    
    @Published var token: TokenModel
    @Published var market: QuoteMarket = LocalUserDefaults.shared.market
    @Published var selectedRangeType: TokenDetailView.ChartRangeType = .d1
    @Published var chartData: LineChartData?
    @Published var balance: Double = 0
    @Published var balanceAsUSD: Double = 0
    @Published var changePercent: Double = 0
    @Published var rate: Double = 0
    
    private var cancelSets = Set<AnyCancellable>()
    
    init(token: TokenModel) {
        self.token = token
        setupObserver()
        fetchAllData()
    }
    
    private func setupObserver() {
        NotificationCenter.default.publisher(for: .quoteMarketUpdated).sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.market = LocalUserDefaults.shared.market
                self?.fetchAllData()
            }
        }.store(in: &cancelSets)

        NotificationCenter.default.publisher(for: .coinSummarysUpdated).sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshSummary()
            }
        }.store(in: &cancelSets)
        
        WalletManager.shared.$coinBalances.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshSummary()
            }
        }.store(in: &cancelSets)
    }
}

// MARK: - Getter

extension TokenDetailViewModel {
    var changePercentString: String {
        let num = String(format: "%.1f", fabsf(Float(changePercent) * 100))
        return "\(num)%"
    }
    
    var balanceString: String {
        return balance.currencyString
    }
    
    var balanceAsUSDString: String {
        return balanceAsUSD.currencyString
    }
    
    var changeIsNegative: Bool {
        return changePercent < 0
    }
    
    var changeColor: Color {
        return changeIsNegative ? Color.LL.Warning.warning2 : Color.LL.Success.success2
    }
    
    var hasRateAndChartData: Bool {
        return token.symbol == SymbolTypeFlow || token.symbol == SymbolTypeFlowUSD
    }
}

// MARK: - Action

extension TokenDetailViewModel {
    func sendAction() {
        LocalUserDefaults.shared.recentToken = token.symbol
        router?.route(to: \.send)
    }
    
    func receiveAction() {
        router?.route(to: \.receive)
    }
    
    func changeSelectRangeTypeAction(_ type: TokenDetailView.ChartRangeType) {
        if selectedRangeType == type {
            return
        }
        
        selectedRangeType = type
        fetchChartData()
    }
    
    func changeMarketAction(_ market: QuoteMarket) {
        if self.market == market {
            return
        }
        
        LocalUserDefaults.shared.market = market
    }
}

// MARK: - Fetch & Refresh

extension TokenDetailViewModel {
    private func fetchAllData() {
        Task {
            try? await WalletManager.shared.fetchBalance()
        }
        
        if hasRateAndChartData {
            fetchChartData()
        }
    }
    
    private func refreshSummary() {
        guard let symbol = token.symbol else {
            return
        }
        
        balance = WalletManager.shared.getBalance(bySymbol: symbol)
        rate = CoinRateCache.cache.getSummary(for: symbol)?.getLastRate() ?? 0
        balanceAsUSD = balance * rate
        changePercent = CoinRateCache.cache.getSummary(for: symbol)?.getChangePercentage() ?? 0
    }
    
    private func fetchChartData() {
        Task {
            let pair = token.getPricePair(market: market)
            let currentRangeType = selectedRangeType
            
            let request = CryptoHistoryRequest(provider: market.rawValue, pair: pair, after: currentRangeType.after, period: "\(currentRangeType.frequency.rawValue)")
            
            do {
                let response: CryptoHistoryResponse = try await Network.request(LilicoAPI.Crypto.history(request))
                
                if currentRangeType != self.selectedRangeType {
                    // selectedRangeType is changed, this is an outdated response
                    return
                }
                
                DispatchQueue.main.async {
                    self.generateChartData(response: response)
                }
            } catch {
                HUD.error(title: "fetch_chart_data_failed".localized)
            }
        }
    }
    
    private func generateChartData(response: CryptoHistoryResponse) {
        let quotes = response.parseMarketQuoteData(rangeType: selectedRangeType)
        let linePoints = quotes.map { $0.generateChartPoint }
        let chartLineStyle = LineStyle(lineColour: ColourStyle(colours: [Color.LL.Primary.salmonPrimary.opacity(0.24), Color.LL.Primary.salmonPrimary.opacity(0)], startPoint: .top, endPoint: .bottom))
        
        let set = LineDataSet(dataPoints: linePoints, style: chartLineStyle)
        let chartStyle = LineChartStyle(infoBoxPlacement: .floating,
                                        infoBoxBorderColour: .LL.Primary.salmonPrimary,
                                        infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
                                        markerType: .vertical(attachment: .point),
                                        yAxisLabelPosition: .trailing,
                                        yAxisLabelFont: .inter(size: 12, weight: .regular),
                                        yAxisLabelColour: Color.LL.Neutrals.neutrals8,
                                        yAxisNumberOfLabels: 4)
        let cd = LineChartData(dataSets: set, chartStyle: chartStyle)
        cd.legends = []
        
        chartData = cd
    }
}