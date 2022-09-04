//
//  ProfileBackupView.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI
import Kingfisher

struct WalletConnectView: RouteableView {
    @StateObject
    private var vm = WalletConnectViewModel()
    
    @StateObject
    var manager = WalletConnectManager.shared
    
    var title: String {
        return "walletconnect".localized
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(manager.activeSessions, id: \.topic) { session in
                    
                    Menu {
                        Button {  
                            Task {
                                await WalletConnectManager.shared.disconnect(topic: session.topic)
                            }
                        } label: {
                            Label("Disconnect", systemImage: "xmark.circle")
                                .foregroundColor(.LL.warning2)
                        }
                    } label: {
                        ItemCell(title: session.peer.name,
                                 url: session.peer.url,
                                 network: String(session.namespaces.values.first?.accounts.first?.reference ?? ""),
                                 icon: session.peer.icons.first ?? "https://lilico.app/placeholder.png")
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 16)
            .roundedBg()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 18)
        }
        .navigationBarItems(trailing:
            Button {
                ScanHandler.scan()
            } label: {
                Image("icon-wallet-scan").renderingMode(.template).foregroundColor(.primary)
            }
        )
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
        
    }
}

extension WalletConnectView {
    struct ItemCell: View {
        let title: String
        let url: String
        let network: String
        let icon: String
        
        var body: some View {
            HStack(spacing: 0) {
                
                KFImage.url(URL(string: icon))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .cornerRadius(8)
                    .padding(.trailing, 15)
                    
                
                VStack {
                    Text(title)
                        .font(.LL.body)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.LL.Neutrals.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(URL(string: url)?.host ?? "")
                        .font(.LL.footnote)
                        .foregroundColor(Color.LL.Neutrals.neutrals9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                ifLet(network) {_,_ in
                    Text(network)
                        .font(.LL.caption)
                        .textCase(.uppercase)
                        .padding(8)
                        .padding(.horizontal, 5)
                        .foregroundColor(Color.LL.Neutrals.neutrals6)
                        .background {
                            Capsule()
                                .fill(Color.LL.outline.opacity(0.5))
                        }
                }
                
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
        }
    }
}

struct Previews_WalletConnectView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConnectView.ItemCell(title: "NBA Top",
                                   url: "https://google.com",
                                   network: "mainnet",
                                   icon: "https://lilico.app/placeholder.png")
        .previewLayout(.sizeThatFits)
    }
}
