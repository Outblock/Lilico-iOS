//
//  ChildAccountLinkView.swift
//  Lilico
//
//  Created by Selina on 15/6/2023.
//

import SwiftUI
import Combine
import Kingfisher

struct ChildAccountLinkView: View {
    @StateObject private var vm: ChildAccountLinkViewModel
    
    init(vm: ChildAccountLinkViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: vm.title)
            
            Group {
                startView.visibility(vm.state == .idle ? .visible : .gone)
                processingView.visibility(vm.state == .processing ? .visible : .gone)
                successView.visibility(vm.state == .success ? .visible : .gone)
                failureView.visibility(vm.state == .fail ? .visible : .gone)
            }
            .padding(.vertical, 8)
            
            Group {
                WalletSendButtonView(buttonText: "hold_to_link".localized) {
                    log.info("user long tap link button")
                    vm.linkAction()
                }
                .visibility(vm.state == .idle || vm.state == .processing ? .visible : .gone)
                
                buttonView
                    .visibility(vm.state == .success || vm.state == .fail ? .visible : .gone)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }
}

// MARK: - Step view
extension ChildAccountLinkView {
    var startView: some View {
        VStack {
            Text("link_account_start_desc_x".localized(vm.fromTitle, UserManager.shared.userInfo?.username ?? ""))
                .font(.inter(size: 14, weight: .regular))
                .foregroundColor(Color.LL.Neutrals.text2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            fromToView
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    var processingView: some View {
        VStack {
            Spacer()
            
            fromToView
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    var successView: some View {
        VStack {
            Text("link_account_success_desc".localized)
                .font(.inter(size: 14, weight: .regular))
                .foregroundColor(Color.LL.Neutrals.text2)
            
            Spacer()
            
            Image("img-link-account-success")
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
    
    var failureView: some View {
        VStack {
            Spacer()
            
            fromToView
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Components
extension ChildAccountLinkView {
    var buttonView: some View {
        Button {
            vm.onConfirmBtnAction()
        } label: {
            Text(vm.state.confirmBtnTitle)
                .foregroundColor(Color.LL.Button.text)
                .font(.inter(size: 14, weight: .bold))
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Button.color)
                .cornerRadius(12)
        }
    }
    
    var fromToView: some View {
        ZStack {
            HStack {
                ChildAccountTargetView(iconURL: vm.logo, name: vm.fromTitle)
                Spacer()
                ChildAccountTargetView(iconURL: UserManager.shared.userInfo?.avatar.convertedAvatarString() ?? "", name: UserManager.shared.userInfo?.meowDomain ?? "")
            }
            
            ProcessingIndicator(state: vm.state)
                .padding(.bottom, 20)
        }
    }
    
    struct ChildAccountTargetView: View {
        @State var iconURL: String
        @State var name: String
        
        var body: some View {
            VStack(spacing: 10) {
                KFImage.url(URL(string: iconURL))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .cornerRadius(32)
                
                Text(name)
                    .font(.inter(size: 12, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .lineLimit(1)
            }
            .frame(width: 130)
        }
    }
    
    struct ProcessingIndicator: View {
        @State var state: ChildAccountLinkViewModel.State
        
        var styleColor: Color {
            return state == .fail ? Color(hex: "#C44536") : Color(hex: "#2AE245")
        }
        
        var barColors: [Color] {
            return [.clear, styleColor, .clear]
        }
        
        var body: some View {
            HStack(spacing: 0) {
                dotView
                
                ZStack {
                    LinearGradient(colors: barColors, startPoint: .leading, endPoint: .trailing)
                        .frame(height: 2)
                    Image("icon-link-account-error")
                        .visibility(state == .fail ? .visible : .gone)
                }
                .frame(maxWidth: .infinity)
                
                dotView
            }
            .frame(width: 114, height: 8)
        }
        
        var dotView: some View {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(styleColor)
                .visibility(state == .idle ? .visible : .gone)
        }
    }
}
