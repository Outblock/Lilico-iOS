//
//  BrowserAuthzView.swift
//  Lilico
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI
import Kingfisher

struct BrowserAuthzView: View {
    @StateObject var vm: BrowserAuthzViewModel
    
    init(vm: BrowserAuthzViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            normalView.visibility(vm.isScriptShowing ? .invisible : .visible)
            scriptView.visibility(vm.isScriptShowing ? .visible : .invisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }
    
    var normalView: some View {
        VStack(spacing: 0) {
            titleView
            
            feeView
                .padding(.top, 12)
            
            scriptButton
                .padding(.top, 8)
            
            Spacer()
            
            actionView
        }
        .padding(.all, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
    }
    
    var titleView: some View {
        HStack(spacing: 18) {
            KFImage.url(URL(string: vm.logo ?? ""))
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text("browser_transaction_request_from".localized)
                    .font(.inter(size: 14))
                    .foregroundColor(Color(hex: "#808080"))
                
                Text(vm.title)
                    .font(.inter(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var feeView: some View {
        HStack(spacing: 12) {
            Image("icon-fee")
            
            Text("browser_transaction_fee".localized)
                .font(.inter(size: 14, weight: .regular))
                .foregroundColor(Color(hex: "#F2F2F2"))
                .lineLimit(1)
            
            Spacer()
            
            Image("Flow")
                .resizable()
                .frame(width: 16, height: 16)
            
            Text(RemoteConfigManager.shared.freeGasEnabled ? "0" : "0.001")
                .font(.inter(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "#FAFAFA"))
                .lineLimit(1)
        }
        .frame(height: 46)
        .padding(.horizontal, 18)
        .background(Color(hex: "#313131"))
        .cornerRadius(12)
    }
    
    var scriptButton: some View {
        Button {
            vm.changeScriptViewShowingAction(true)
        } label: {
            HStack(spacing: 12) {
                Image("icon-script")
                
                Text("browser_script".localized)
                    .font(.inter(size: 14, weight: .regular))
                    .foregroundColor(Color(hex: "#F2F2F2"))
                    .lineLimit(1)
                
                Spacer()
                
                Image("icon-search-arrow")
                    .resizable()
                    .frame(width: 12, height: 12)
            }
            .frame(height: 46)
            .padding(.horizontal, 18)
            .background(Color(hex: "#313131"))
            .cornerRadius(12)
        }
    }
    
    var actionView: some View {
        WalletSendButtonView {
            vm.didChooseAction(true)
        }
    }
    
    var scriptView: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Button {
                        vm.changeScriptViewShowingAction(false)
                    } label: {
                        Image("icon-back-arrow-grey")
                            .frame(height: 72)
                            .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
                
                Text("browser_script_title".localized)
                    .font(.inter(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#E8E8E8"))
            }
            .frame(height: 72)
            
            ScrollView(.vertical, showsIndicators: false) {
                Text(vm.cadence.trim())
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#B2B2B2"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.all, 18)
                    .background(Color(hex: "#313131"))
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color(hex: "#282828", alpha: 1))
        .transition(.move(edge: .trailing))
    }
}
