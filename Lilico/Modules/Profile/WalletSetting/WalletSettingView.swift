//
//  WalletSettingView.swift
//  Lilico
//
//  Created by Hao Fu on 7/9/2022.
//

import SwiftUI

struct WalletSettingView: RouteableView {
    
    var title: String {
        "wallet".localized.capitalized
    }
    
    @State
    var isOn: Bool = true
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            
            ScrollView {
                VStack(spacing: 16) {
                        VStack(spacing: 0) {
                            Button {
                                Router.route(to: RouteMap.Profile.privateKey)
                            } label: {
                                ProfileSecureView.ItemCell(title: "private_key".localized, style: .arrow, isOn: false, toggleAction: nil)
                            }
                            
                            Divider().foregroundColor(.LL.Neutrals.background)
                            
                            Button {
                                Router.route(to: RouteMap.Profile.manualBackup)
                            } label: {
                                ProfileSecureView.ItemCell(title: "recovery_phrase".localized, style: .arrow, isOn: false, toggleAction: nil)
                                    .contentShape(Rectangle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .roundedBg()
                    
                    VStack(spacing: 0) {
                        
                        HStack {
                            Text("Free Gas Fee".localized)
                                .font(.inter(size: 16, weight: .medium))
                                .foregroundColor(Color.LL.Neutrals.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                            
                            Toggle(isOn: $isOn) {
                                
                            }
                            .tint(.LL.Primary.salmonPrimary)
                            .onChange(of: isOn) { value in
        //                        toggleAction?(value)
                            }
                            
                        }
                        
                        Text("Allow lilico to pay the gas fee for all my transactions".localized)
                            .font(.inter(size: 12, weight: .regular))
                            .foregroundColor(Color.LL.Neutrals.neutrals7)
                            .frame(maxWidth: .infinity, alignment: .leading)


                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .padding(.horizontal, 16)
                    .roundedBg()


                    
                }.padding(.horizontal, 18)
                
            }
            
            VStack(alignment: .trailing) {
                
                Button {
                    
                } label: {
                    Text("Reset Wallet")
                        .frame(maxWidth: .infinity)
                        .frame(width: .infinity, height: 56)
                        .background(.LL.Warning.warning2)
                        .cornerRadius(16)
                        .foregroundColor(.LL.background)
                }
                .padding(.horizontal, 18)
            }
                        
        }
        .backgroundFill(.LL.background)
        .applyRouteable(self)
    }
}

struct WalletSettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletSettingView()
        }
    }
}
