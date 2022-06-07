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

struct DeveloperModeView: View {
    @EnvironmentObject private var router: ProfileCoordinator.Router
    @StateObject private var lud = LocalUserDefaults.shared
    
    var body: some View {
        List {
            Section {
                let isMainnet = lud.flowNetwork == .mainnet
                Cell(sysImageTuple: (isMainnet ? .checkmarkSelected : .checkmarkUnselected, isMainnet ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: "Mainnet", desc: isMainnet ? "Selected" : "")
                    .onTapGestureOnBackground {
                        if lud.flowNetwork != .mainnet {
                            lud.flowNetwork = .mainnet
                        }
                    }
                Cell(sysImageTuple: (isMainnet ? .checkmarkUnselected : .checkmarkSelected, isMainnet ? .LL.Neutrals.neutrals1 : .LL.Primary.salmonPrimary), title: "Testnet", desc: isMainnet ? "" : "Selected")
                    .onTapGestureOnBackground {
                        if lud.flowNetwork != .testnet {
                            lud.flowNetwork = .testnet
                        }
                    }
            } header: {
                Text("Switch Network")
            }
            .listRowInsets(.zero)
        }
        .backgroundFill(.LL.Neutrals.background)
        .navigationTitle("Developer Mode")
        .navigationBarTitleDisplayMode(.inline)
        .buttonStyle(.plain)
        .addBackBtn {
            router.pop()
        }
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
