//
//  TokenDetailView.swift
//  Lilico
//
//  Created by Selina on 30/6/2022.
//

import SwiftUI

struct TokenDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TokenDetailView()
    }
}

struct TokenDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let lightGradientColors: [Color] = [.white.opacity(0), Color(hex: "#E6E6E6").opacity(0), Color(hex: "#E6E6E6").opacity(1)]
    private let darkGradientColors: [Color] = [.white.opacity(0), .white.opacity(0), Color(hex: "#282828").opacity(1)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                summaryView
                moreView
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
}
