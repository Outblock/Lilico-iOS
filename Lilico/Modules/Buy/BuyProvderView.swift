//
//  BuyProvderView.swift
//  Lilico
//
//  Created by Hao Fu on 8/9/2022.
//

import SwiftUI

struct BuyProvderView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("choose_provider".localized)
                .font(.inter(size: 20, weight: .semibold))
            
            Divider()
            
            Button {
                
            } label: {
                Color(hex: "#242424")
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .overlay {
                        Image("moonpay")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                    }
                    .cornerRadius(12)
            }.buttonStyle(ScaleButtonStyle())
            
            Button {
                
                if LocalUserDefaults.shared.flowNetwork == .testnet {
                    HUD.error(title: "Incorrect network", message: "Please switch to mainnet to continue")
                    return
                }
                
                guard let address = WalletManager.shared.getPrimaryWalletAddress(),
                      let url = URL(string: "https://pay.coinbase.com/buy/input?appId=d22a56bd-68b7-4321-9b25-aa357fc7f9ce&destinationWallets=%5B%7B%22address%22%3A%22\(address)%22%2C%22blockchains%22%3A%5B%22flow%22%5D%7D%5D")else {
                    return
                }
                
                Router.dismiss(animated: true) {
                    Router.route(to: RouteMap.Explore.browser(url))
                }
                
            } label: {
                Color(hex: "#0052FF")
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .overlay {
                        Image("coinbase-pay")
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                    }
                    .cornerRadius(12)
            }.buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
        }
        .padding(.top, 20)
        .padding(.horizontal, 18)
        .background(Color.LL.background)
    }
}

struct BuyProvderView_Previews: PreviewProvider {
    static var previews: some View {
        BuyProvderView()
    }
}
