//
//  EmptyWalletView.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import SceneKit
import SPConfetti
import SwiftUI
import SwiftUIX
import Kingfisher

struct EmptyWalletView: View {
    @StateObject private var vm = EmptyWalletViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            topContent
                .padding(.horizontal, 30)
                .padding(.top, 50)
                .padding(.bottom, 36)
            
            recentListContent
                .padding(.horizontal, 41)
                .visibility(vm.placeholders.isEmpty ? .invisible : .visible)
            
            bottomContent
                .padding(.horizontal, 41)
                .padding(.bottom, 80)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill {
            Image("login-bg")
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    var topContent: some View {
        VStack(spacing: 4) {
            Text("welcome".localized)
                .font(.montserrat(size: 52, weight: .bold))
                .foregroundColor(.white)
            
            Text("welcome_sub_desc".localized)
                .font(.montserrat(size: 14, weight: .light))
                .foregroundColor(.white)
        }
    }
    
    var bottomContent: some View {
        VStack(spacing: 24) {
            Button {
                vm.createNewAccountAction()
            } label: {
                ZStack {
                    HStack(spacing: 8) {
                        Image("wallet-create-icon")
                            .frame(width: 24, height: 24)
                        
                        Text("create_wallet".localized)
                            .font(.inter(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Primary.salmonPrimary)
                .contentShape(Rectangle())
                .cornerRadius(29)
                .shadow(color: Color.black.opacity(0.12), x: 0, y: 4, blur: 24)
            }
            
            Button {
                vm.loginAccountAction()
            } label: {
                ZStack {
                    HStack(spacing: 8) {
                        Image("wallet-login-icon")
                            .frame(width: 24, height: 24)
                        
                        Text("import_wallet".localized)
                            .font(.inter(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))
                    }
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(.white)
                .contentShape(Rectangle())
                .cornerRadius(29)
                .shadow(color: Color.black.opacity(0.08), x: 0, y: 4, blur: 24)
            }
        }
    }
    
    var recentListContent: some View {
        VStack(spacing: 16) {
            Text("registerd_accounts".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(vm.placeholders, id: \.uid) { placeholder in
                        Button {
                            vm.switchAccountAction(placeholder.uid)
                        } label: {
                            createRecentLoginCell(placeholder)
                        }
                    }
                }
            }
        }
    }
    
    func createRecentLoginCell(_ placeholder: EmptyWalletViewModel.Placeholder) -> some View {
        HStack(spacing: 16) {
            KFImage.url(URL(string: placeholder.avatar.convertedAvatarString()))
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .cornerRadius(18)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("@\(placeholder.username)")
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundColor(Color(hex: "#333333"))
                
                Text("\(placeholder.address)")
                    .font(.inter(size: 12, weight: .regular))
                    .foregroundColor(Color(hex: "#808080"))
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.5))
        .contentShape(Rectangle())
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.04), x: 0, y: 4, blur: 16)
    }
}
