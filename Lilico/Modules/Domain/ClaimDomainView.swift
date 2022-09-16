//
//  ClaimDomainView.swift
//  Lilico
//
//  Created by Selina on 15/9/2022.
//

import SwiftUI

struct ClaimDomainView: View {
    var body: some View {
        VStack {
            
        }
    }
}

extension ClaimDomainView {
    var headerView: some View {
        ZStack {
            Image("bg-domain-claim-header")
                .resizable()
                .frame(maxWidth: .infinity)
                .aspectRatio(CGSize(width: 375, height: 172), contentMode: .fill)
        }
        .frame(maxWidth: .infinity)
    }
    
    var headerTitleView: some View {
        HStack(spacing: 0) {
            Image("AppIcon")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            
            Text("lilico".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.LL.Neutrals.text)
                .padding(.leading, 3)
            
            Image("icon-domain-x")
                .padding(.horizontal, 12)
            
            Image("icon-flowns")
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            
            Text("flowns".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.LL.Neutrals.text)
                .padding(.leading, 3)
        }
    }
}
