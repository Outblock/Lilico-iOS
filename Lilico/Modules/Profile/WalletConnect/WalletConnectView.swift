//
//  ProfileBackupView.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI
import Kingfisher
import Lottie

struct WalletConnectView: RouteableView {
    @StateObject
    private var vm = WalletConnectViewModel()
    
    @StateObject
    var manager = WalletConnectManager.shared
    
    var title: String {
        return "walletconnect".localized
    }
    
    var body: some View {
        if manager.activeSessions.count > 0 {
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
            .navigationBarItems(center: HStack {
                Image("walletconnect")
                    .frame(width: 24, height: 24)
                Text("walletconnect".localized)
                    .font(.LL.body)
                    .fontWeight(.semibold)
            },
                                trailing:
                                    Button {
                ScanHandler.scan()
            } label: {
                Image("icon-wallet-scan")
                    .renderingMode(.template)
                    .foregroundColor(.primary)
            }
            )
            .backgroundFill(Color.LL.Neutrals.background)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(navigationBarTitleDisplayMode)
            .navigationBarHidden(isNavigationBarHidden)
        } else {
            WalletConnectView.EmptyView()
                .backgroundFill(Color.LL.Neutrals.background)
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(navigationBarTitleDisplayMode)
                .navigationBarHidden(isNavigationBarHidden)
                .navigationBarItems(center: HStack {
                    Image("walletconnect")
                        .frame(width: 24, height: 24)
                    Text("walletconnect".localized)
                        .font(.LL.body)
                        .fontWeight(.semibold)
                },
                                    trailing:
                                        Button {
                    ScanHandler.scan()
                } label: {
                    Image("icon-wallet-scan")
                        .renderingMode(.template)
                        .foregroundColor(.primary)
                }
                )
        }
        
    }
}

extension WalletConnectView {
    struct EmptyView: View {
        
        let animationView = AnimationView(name: "QRScan", bundle: .main)
        
        var body: some View {
            VStack(alignment: .center, spacing: 18) {
                Spacer()
                ResizableLottieView(lottieView: animationView,
                                    color: Color(hex: "#3B99FC"))
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                
                Text("Scan to Connect")
                    .foregroundColor(.LL.text)
                    .font(.LL.title2)
                    .fontWeight(.bold)
                
                Text("With WalletConnect, you can connect your wallet with hundreds of apps")
                    .font(.LL.callout)
                    .foregroundColor(.LL.Neutrals.neutrals6)
                    .multilineTextAlignment(.center)
                
                Button {
                    ScanHandler.scan()
                } label: {
                    Text("New Connection")
                        .font(.LL.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white)
                        .padding(15)
                        .background(Color(hex: "#3B99FC"))
                        .cornerRadius(12)
                }
                .padding(.top, 12)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear{
                animationView.play(toProgress: .infinity, loopMode: .loop)
            }
        }
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
        //        WalletConnectView.ItemCell(title: "NBA Top",
        //                                   url: "https://google.com",
        //                                   network: "mainnet",
        //                                   icon: "https://lilico.app/placeholder.png")
        //        .previewLayout(.sizeThatFits)
        
        WalletConnectView.EmptyView()
    }
}
