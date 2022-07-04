//
//  TokenDetailView.swift
//  Lilico
//
//  Created by Selina on 30/6/2022.
//

import SwiftUI
import SwiftUICharts

struct TokenDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDetailView()
//        VStack {
//            TokenDetailView.SelectButton(isSelect: false)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .backgroundFill(.LL.Neutrals.background)
    }
}

struct TokenDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var vm = TokenDetailViewModel()
    
    private let lightGradientColors: [Color] = [.white.opacity(0), Color(hex: "#E6E6E6").opacity(0), Color(hex: "#E6E6E6").opacity(1)]
    private let darkGradientColors: [Color] = [.white.opacity(0), .white.opacity(0), Color(hex: "#282828").opacity(1)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                summaryView
                moreView
                chartContainerView
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .buttonStyle(.plain)
        //        .backgroundFill(.LL.deepBg)
        .backgroundFill(Color.purple)
    }
    
    var summaryView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .leading) {
                HStack(spacing: 5) {
                    Text("Flow")
                        .foregroundColor(.LL.Neutrals.neutrals1)
                        .font(.inter(size: 16, weight: .semibold))
                    Image("icon-right-arrow")
                }
                .frame(height: 32)
                .padding(.trailing, 10)
                .padding(.leading, 90)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.linearGradient(
                            colors: colorScheme == .dark ? darkGradientColors : lightGradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                }
                
                Image("")
                    .frame(width: 64, height: 64)
                    .background(.LL.Neutrals.note)
                    .clipShape(Circle())
                    .padding(.top, -12)
                    .padding(.leading, 18)
            }
            .padding(.leading, -18)
            
            HStack(alignment: .bottom, spacing: 6) {
                Text("1580.88")
                    .foregroundColor(.LL.Neutrals.neutrals1)
                    .font(.inter(size: 32, weight: .semibold))
                
                Text("FLOW")
                    .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals8)
                    .font(.inter(size: 14, weight: .medium))
                    .padding(.bottom, 5)
            }
            .padding(.top, 15)
            
            Text("$292929 USD")
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 16, weight: .medium))
                .padding(.top, 3)
            
            HStack(spacing: 13) {
                Button {
                    
                } label: {
                    Text("send_uppercase".localized)
                        .foregroundColor(.white)
                        .font(.inter(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(.LL.Primary.salmonPrimary)
                        .cornerRadius(12)
                }
                
                Button {
                    
                } label: {
                    Text("receive_uppercase".localized)
                        .foregroundColor(.white)
                        .font(.inter(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(.LL.Primary.salmonPrimary)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 14)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }
    
    var moreView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text("Get more FLOW")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 16, weight: .semibold))
                
                Text("Stake tokens and earn rewards")
                    .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals8)
                    .font(.inter(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Image("icon-bitcoin")
        }
        .frame(height: 68)
        .padding(.horizontal, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }
    
    var chartContainerView: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("recent_price".localized)
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 16, weight: .semibold))
                    
                    HStack(spacing: 4) {
                        Text("$127.80")
                            .foregroundColor(.LL.Neutrals.text)
                            .font(.inter(size: 14, weight: .regular))
                        
                        HStack(spacing: 4) {
                            Image(systemName: .arrowTriangleUp)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 9, height: 7)
                                .foregroundColor(.LL.Success.success2)
                            
                            Text("5.2%")
                                .foregroundColor(.LL.Success.success2)
                                .font(.inter(size: 12, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .frame(height: 18)
                        .background {
                            Color.LL.Success.success3
                                .cornerRadius(4)
                                .opacity(0.12)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 18)
                }
                sourceSwitchButton
            }
            .padding(.horizontal, 18)
            
            if colorScheme == .dark {
                Color(hex: "#262626")
                    .opacity(0.64)
                    .frame(height: 1)
            } else {
                Color.LL.Neutrals.neutrals10
                    .opacity(0.64)
                    .frame(height: 1)
            }
            
            chartRangeView
            chartView
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }
    
    var chartRangeView: some View {
        HStack(spacing: 0) {
            ForEach(ChartRangeType.allCases, id: \.self) { type in
                SelectButton(title: type.title, isSelect: vm.selectedRangeType == type)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 7)
    }
}

// MARK: - Chart

extension TokenDetailView {
    var chartView: some View {
        FilledLineChart(chartData: vm.chartData)
            .filledTopLine(chartData: vm.chartData,
                           lineColour: chartFilledTopLineColor,
                           strokeStyle: chartFilledTopLineStrokeStyle)
            .touchOverlay(chartData: vm.chartData, specifier: "%.2f")
            .floatingInfoBox(chartData: vm.chartData)
            .yAxisLabels(chartData: vm.chartData, specifier: "%.2f")
            .id(vm.chartData.id)
            .frame(height: 163)
            .padding(.horizontal, 18)
    }
    
    var chartFilledTopLineColor: ColourStyle {
        return ColourStyle(colour: Color.LL.Primary.salmonPrimary)
    }
    
    var chartFilledTopLineStrokeStyle: StrokeStyle {
        return StrokeStyle(lineWidth: 1, lineCap: .round)
    }
}

extension TokenDetailView {
    var sourceSwitchButton: some View {
        Menu {
            Button {
                
            } label: {
                HStack {
                    Image("icon_nft_add")
                    Text("binance".localized)
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .regular))
                }
            }

            Button {
                
            } label: {
                Text("kraken".localized)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
            }
            
            Button {
                
            } label: {
                Text("huobi".localized)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .regular))
            }
        } label: {
            VStack(alignment: .trailing, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: String.arrowDown)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals6)
                    
                    Text("data_from".localized)
                        .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals6)
                        .font(.inter(size: 14, weight: .regular))
                }
                
                HStack(spacing: 6) {
                    Image(systemName: String.arrowDown)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals6)
                    
                    Text("Huobi")
                        .foregroundColor(colorScheme == .dark ? .LL.Neutrals.neutrals9 : .LL.Neutrals.neutrals6)
                        .font(.inter(size: 14, weight: .regular))
                }
            }
        }
    }
}

extension TokenDetailView {
    struct SelectButton: View {
        @Environment(\.colorScheme) var colorScheme
        let title: String
        let isSelect: Bool
        
        var body: some View {
            Button {
                
            } label: {
                Text(title)
                    .foregroundColor(labelColor)
                    .font(labelFont)
                    .frame(height: 26)
                    .padding(.horizontal, 7)
                    .background {
                        labelBgColor
                            .cornerRadius(8)
                            .visibility(isSelect ? .visible : .invisible)
                    }
            }
        }
        
        private var labelBgColor: Color {
            return colorScheme == .dark ? Color.LL.Neutrals.neutrals10 : Color.LL.Neutrals.outline
        }
        
        private var labelColor: Color {
            if colorScheme == .dark {
                return isSelect ? Color.LL.Neutrals.text : Color.LL.Neutrals.note
            } else {
                return isSelect ? Color.LL.Neutrals.text : Color.LL.Neutrals.note
            }
        }
        
        private var labelFont: Font {
            return isSelect ? .inter(size: 12, weight: .semibold) : .inter(size: 12, weight: .regular)
        }
    }
}
