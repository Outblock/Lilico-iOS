//
//  DeveloperModeView.swift
//  Lilico
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI

struct DeveloperModeView_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperModeView()
    }
}

struct DeveloperModeView: RouteableView {
    @StateObject private var lud = LocalUserDefaults.shared
    
    var title: String {
        return "developer_mode".localized
    }
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                Text("switch_network".localized)
                    .font(.LL.footnote)
                    .foregroundColor(.LL.Neutrals.neutrals6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    Section {
                        let isMainnet = lud.flowNetwork == .mainnet
                        Cell(sysImageTuple: (isMainnet ? .checkmarkSelected : .checkmarkUnselected, isMainnet ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: "Mainnet", desc: isMainnet ? "Selected" : "")
                            .onTapGestureOnBackground {
                                if lud.flowNetwork != .mainnet {
                                    lud.flowNetwork = .mainnet
                                }
                            }
                        Divider()
                        Cell(sysImageTuple: (isMainnet ? .checkmarkUnselected : .checkmarkSelected, isMainnet ? .LL.Neutrals.neutrals1 : .LL.Primary.salmonPrimary), title: "Testnet", desc: isMainnet ? "" : "Selected")
                            .onTapGestureOnBackground {
                                if lud.flowNetwork != .testnet {
                                    lud.flowNetwork = .testnet
                                }
                            }
                    }
                    .background(.LL.bgForIcon)
                }
                .cornerRadius(16)
            }
            .padding(.horizontal, 18)
        }
        .background(
            Color.LL.Neutrals.background.ignoresSafeArea()
        )
        .applyRouteable(self)
    }
}

extension DeveloperModeView {
    struct Cell: View {
        let sysImageTuple: (String, Color)
        let title: String
        let desc: String
        
        var body: some View {
            HStack {
                Image(systemName: sysImageTuple.0).foregroundColor(sysImageTuple.1)
                Text(title).font(.inter()).frame(maxWidth: .infinity, alignment: .leading)
                Text(desc).font(.inter()).foregroundColor(.LL.Neutrals.note)
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
        }
    }
}
