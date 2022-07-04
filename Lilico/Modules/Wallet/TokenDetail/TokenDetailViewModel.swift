//
//  TokenDetailViewModel.swift
//  Lilico
//
//  Created by Selina on 1/7/2022.
//

import SwiftUI
import Combine
import SwiftUICharts

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
            return LineChartDataPoint(value: closePrice, xAxisLabel: "ha", description: date.ymdString, date: date)
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
    }
}

class TokenDetailViewModel: ObservableObject {
    @Published var selectedRangeType: TokenDetailView.ChartRangeType = .d1
    @Published var chartData: LineChartData
    
    init() {
        chartData = TokenDetailViewModel.generateTestChartData()
    }
    
    static func generateTestChartData() -> LineChartData {
        var rawPoints = [TokenDetailView.Quote]()
        let startTime = Date().timeIntervalSince1970
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 7 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.62, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 6 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.61, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 5 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.59, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 4 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.61, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 3 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.58, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 2 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.59, volume: 0, quoteVolume: 0))
        rawPoints.append(TokenDetailView.Quote(closeTime: startTime - 1 * 3600 * 24, openPrice: 0, highPrice: 0, lowPrice: 0, closePrice: 1.56, volume: 0, quoteVolume: 0))
        
        let linePoints = rawPoints.map { $0.generateChartPoint }
        let chartLineStyle = LineStyle(lineColour: ColourStyle(colours: [Color.LL.Primary.salmonPrimary.opacity(0.24), Color.LL.Primary.salmonPrimary.opacity(0)], startPoint: .top, endPoint: .bottom))
        let set = LineDataSet(dataPoints: linePoints, pointStyle: PointStyle(), style: chartLineStyle)
        
        let chartStyle = LineChartStyle(infoBoxPlacement: .floating,
                                        infoBoxBorderColour: .LL.Primary.salmonPrimary,
                                        infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
                                        markerType: .vertical(attachment: .point),
                                        yAxisLabelPosition: .trailing,
                                        yAxisLabelFont: .inter(size: 12, weight: .regular),
                                        yAxisLabelColour: Color.LL.Neutrals.neutrals8,
                                        yAxisNumberOfLabels: 4)
        
        let chartData = LineChartData(dataSets: set, chartStyle: chartStyle)
        chartData.legends = []
        
        return chartData
    }
}
