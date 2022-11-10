//
//  StakingListView.swift
//  Lilico
//
//  Created by Selina on 10/11/2022.
//

import SwiftUI
import Kingfisher
import UIKit

struct StakingListView: RouteableView {
    @State var dataList = 0...1
    
    var title: String {
        return "staking_list_title".localized
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .large
    }
    
    var body: some View {
        VStack {
            listView
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .buttonStyle(.plain)
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
    }
    
    var listView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(dataList, id: \.self) { _ in
                    createListCell()
                }
            }
        }
    }
    
    func createListCell() -> some View {
        VStack(spacing: 0) {
            
            // header
            HStack(spacing: 0) {
                KFImage.url(nil)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                
                Text("Lilico")
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .padding(.leading, 8)
                
                Text("+5.2%")
                    .font(.inter(size: 12, weight: .semibold))
                    .foregroundColor(Color.LL.Success.success1)
                    .padding(.horizontal, 5)
                    .frame(height: 18)
                    .background(Color.LL.Success.success4)
                    .cornerRadius(12)
                    .padding(.leading, 8)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("staking_claim".localized)
                        .font(.inter(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .frame(height: 26)
                        .background(Color.LL.Primary.salmonPrimary)
                        .cornerRadius(16)
                }
            }
            .frame(height: 56)
            
            // detail
            HStack(spacing: 12) {
                
                // amount
                VStack(alignment: .leading, spacing: 13) {
                    Text("staking_amount".localized)
                        .font(.inter(size: 12, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text4)
                    
                    Text(AttributedString(numAttributedString()))
                }
                .padding(.all, 13)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Color.LL.deepBg)
                .cornerRadius(16)
                
                // rewards
                VStack(alignment: .leading, spacing: 13) {
                    Text("staking_rewards".localized)
                        .font(.inter(size: 12, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text4)
                    
                    Text(AttributedString(numAttributedString()))
                }
                .padding(.all, 13)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .background(Color.LL.deepBg)
                .cornerRadius(16)
            }
            .frame(height: 76)
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .background {
            Color.LL.Neutrals.background.cornerRadius(16)
        }
    }
    
    func numAttributedString() -> NSAttributedString {
        let boldAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.interBold(size: 18), .foregroundColor: UIColor.LL.Neutrals.text]
        let normalAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.interMedium(size: 12), .foregroundColor: UIColor.LL.Neutrals.text]
        
        let numStr = NSMutableAttributedString(string: "309.80 ", attributes: boldAttrs)
        let normalStr = NSAttributedString(string: "Flow", attributes: normalAttrs)
        
        numStr.append(normalStr)
        
        return numStr
    }
}
