//
//  SelectProviderView.swift
//  Lilico
//
//  Created by Selina on 14/11/2022.
//

import SwiftUI
import Kingfisher

struct SelectProviderView: RouteableView {
    @State var dataList = 0..<3
    @State var dataList2 = 3..<6
    
    var title: String {
        return "staking_select_provider".localized
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .large
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                createSectionTitleView("staking_recommend".localized)
                ForEach(dataList, id: \.self) { _ in
                    createProviderView()
                }
                
                createSectionTitleView("staking_provider".localized)
                ForEach(dataList2, id: \.self) { _ in
                    createProviderView()
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
    }
    
    func createSectionTitleView(_ title: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(Color.LL.Neutrals.neutrals4)
                .font(.inter(size: 14, weight: .bold))
            
            Spacer()
        }
        .padding(.top, 14)
    }
    
    func createProviderView() -> some View {
        HStack(spacing: 0) {
            KFImage.url(nil)
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 34, height: 34)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Lilico")
                    .foregroundColor(Color.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .bold))
                
                HStack(spacing: 0) {
                    Text("Lico")
                        .foregroundColor(Color.LL.Neutrals.text2)
                        .font(.inter(size: 10, weight: .medium))
                    
                    KFImage.url(nil)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                        .clipShape(Circle())
                        .padding(.leading, 12)
                    
                    Text("Lico")
                        .foregroundColor(Color.LL.Neutrals.text2)
                        .font(.inter(size: 10, weight: .medium))
                        .padding(.leading, 4)
                }
            }
            .padding(.leading, 12)
            .frame(alignment: .leading)
            
            Spacer()
            
            ZStack {
                Color.LL.Primary.salmonPrimary
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("12.04%")
                        .foregroundColor(Color.white)
                        .font(.inter(size: 16, weight: .semibold))
                    
                    Text("Stake")
                        .foregroundColor(Color(hex: "#865CFF"))
                        .font(.inter(size: 10, weight: .medium))
                }
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 92)
            .frame(maxHeight: .infinity)
            .cornerRadius(12, corners: [.bottomLeft])
        }
        .padding(.leading, 16)
        .frame(height: 58)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(12)
        .padding(.top, 8)
    }
}
