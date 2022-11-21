//
//  StakingDetailView.swift
//  Lilico
//
//  Created by Selina on 18/11/2022.
//

import SwiftUI

struct StakingDetailView: RouteableView {
    var title: String {
        return "staking_detail".localized
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .large
    }
    
    var body: some View {
        VStack {
            summaryCardView
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .buttonStyle(.plain)
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
    }
    
    var summaryCardView: some View {
        VStack(alignment:.leading, spacing: 0) {
            Text("staked_flow".localized)
                .font(.inter(size: 14, weight: .bold))
                .foregroundColor(Color.LL.Neutrals.text)
                .padding(.top, 18)
                .padding(.horizontal, 18)
            
            Spacer()
            
            HStack(alignment: .bottom, spacing: 0) {
                Text("$1580.88")
                    .font(.inter(size: 32, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("USD")
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .padding(.leading, 4)
                    .padding(.bottom, 5)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 15)
            
            HStack(spacing: 4) {
                Image("flow")
                    .resizable()
                    .frame(width: 16, height: 16)
                
                Text("90.76")
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("Flow")
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Divider()
                    .frame(width: 1, height: 12)
                    .background(Color.LL.Neutrals.note)
                
                Text("1299.87")
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Text("stake_flow_available".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 15)
            .padding(.horizontal, 18)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("staking_rewards".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .padding(.bottom, 4)
                
                HStack(alignment: .bottom, spacing: 0) {
                    Text("187.00")
                        .font(.inter(size: 24, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Text("Flow")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text)
                        .padding(.leading, 6)
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("domain_claim".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundColor(Color.LL.Neutrals.text)
                            .frame(width: 80, height: 32)
                            .background(Color.LL.deepBg)
                            .cornerRadius(12)
                    }
                }
            }
            .frame(height: 90)
            .padding(.horizontal, 18)
            .background {
                Image("bg-stake-detail-card-2")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(height: 236)
        .background {
            Image("bg-stake-detail-card")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
        .cornerRadius(12)
    }
}
