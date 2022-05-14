//
//  EmptyNFTView.swift
//  Lilico
//
//  Created by cat on 2022/5/13.
//

import SwiftUI

struct EmptyNFTView: View {
    var body: some View {
        ZStack {
            //TODO: 这里需要一个背景图片
            VStack {
                Image("")
                Text("We find nothing here.")
                    .font(.LL.mindTitle)
                    .foregroundColor(.LL.Neutrals.neutrals3)
                    .padding(2)
                Text("Looking forward to your new discovery.")
                    .font(.LL.body)
                    .foregroundColor(.LL.Neutrals.neutrals8)
                Spacer()
                    .frame(height: 18)
                Button {
                    
                } label: {
                    Text("Get new NFTs")
                        .foregroundColor(.LL.Primary.salmonPrimary)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 44)
                .background(Color.LL.Primary.salmonPrimary.opacity(0.08))
                .cornerRadius(12)
                .clipped()
                

            }
        }
    }
}

struct EmptyNFTView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyNFTView()
    }
}
