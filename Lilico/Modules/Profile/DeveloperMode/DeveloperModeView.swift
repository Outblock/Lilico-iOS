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
    @StateObject private var vm: DeveloperModeViewModel = DeveloperModeViewModel()
    
    @AppStorage("isDeveloperMode") private var isDeveloperMode = false
    
    var title: String {
        return "developer_mode".localized
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                HStack {
                    Toggle("developer_mode".localized, isOn: $isDeveloperMode)
                        .toggleStyle(SwitchToggleStyle(tint: .LL.Primary.salmonPrimary))
                }
                .frame(height: 64)
                .padding(.horizontal, 16)
            }
            .background(.LL.bgForIcon)
            .cornerRadius(16)
            .padding(.horizontal, 18)
            
            if isDeveloperMode {
                
                VStack {
                    Text("switch_network".localized)
                        .font(.LL.footnote)
                        .foregroundColor(.LL.Neutrals.neutrals3)
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
                    
                    Text("watch_address".localized)
                        .font(.LL.footnote)
                        .foregroundColor(.LL.Neutrals.neutrals3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 0) {
                        Section {
                            Cell(sysImageTuple: (vm.isCustomAddress ? .checkmarkUnselected : .checkmarkSelected, vm.isCustomAddress ? .LL.Neutrals.neutrals1 : .LL.Primary.salmonPrimary), title: "my_own_address".localized, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction("")
                                }
                            
                            Divider()
                            
                            Cell(sysImageTuple: (vm.isDemoAddress ? .checkmarkSelected : .checkmarkUnselected, vm.isDemoAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: vm.demoAddress, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction(vm.demoAddress)
                                }
                            
                            Divider()
                            
                            Cell(sysImageTuple: (vm.isSVGDemoAddress ? .checkmarkSelected : .checkmarkUnselected, vm.isSVGDemoAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1), title: vm.svgDemoAddress, desc: "")
                                .onTapGestureOnBackground {
                                    vm.changeCustomAddressAction(vm.svgDemoAddress)
                                }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: vm.isCustomAddress ? .checkmarkSelected : .checkmarkUnselected)
                                    .foregroundColor(vm.isCustomAddress ? .LL.Primary.salmonPrimary : .LL.Neutrals.neutrals1)
                                Text("custom_address".localized)
                                    .font(.inter())
                                
                                TextField("", text: $vm.customAddressText)
                                    .autocorrectionDisabled()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 40)
                                    .padding(.horizontal, 10)
                                    .background(.LL.Neutrals.background)
                                    .cornerRadius(8)
                                    .onChange(of: vm.customAddressText) { _ in
                                        let trimedAddress = vm.customAddressText.trim()
                                        if trimedAddress == vm.customWatchAddress {
                                            return
                                        }
                                        
                                        DispatchQueue.main.async {
                                            vm.changeCustomAddressAction(vm.customAddressText.trim())
                                        }
                                    }
                            }
                            .frame(height: 64)
                            .padding(.horizontal, 16)
                            
                        }
                        .background(.LL.bgForIcon)
                    }
                    .cornerRadius(16)
                }
                .padding(.horizontal, 18)
            }
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
