//
//  BrowserAuthnView.swift
//  Lilico
//
//  Created by Selina on 6/9/2022.
//

import SwiftUI
import Kingfisher

struct BrowserAuthnView: View {
    @StateObject var vm: BrowserAuthnViewModel
    
    init(vm: BrowserAuthnViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            titleView
            
            sourceView
                .padding(.top, 12)
            
            detailView
                .padding(.bottom, 36)
                .padding(.top, 18)
            
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
                Text("browser_connecting_to".localized)
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
    
    var sourceView: some View {
        HStack(spacing: 12) {
            Image("icon-globe")
            
            Text(vm.urlString)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
        }
        .frame(height: 46)
        .padding(.horizontal, 18)
        .background(Color(hex: "#313131"))
        .cornerRadius(12)
    }
    
    var detailView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("browser_app_like_to".localized)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#666666"))
                .padding(.bottom, 18)
            
            createAuthDetailView(text: "browser_authn_tips1".localized)
                .padding(.bottom, 12)
            
            createAuthDetailView(text: "browser_authn_tips2".localized)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.all, 18)
        .background(Color(hex: "#313131"))
        .cornerRadius(12)
    }
    
    var actionView: some View {
        HStack(spacing: 11) {
            Button {
                vm.didChooseAction(false)
            } label: {
                Text("cancel".localized)
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: "#313131"))
                    .cornerRadius(12)
                    
            }
            
            Button {
                vm.didChooseAction(true)
            } label: {
                Text("browser_connect".localized)
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.LL.Primary.salmonPrimary)
                    .cornerRadius(12)
            }
        }
    }
    
    func createAuthDetailView(text: String) -> some View {
        HStack(spacing: 12) {
            Image("icon-right-mark")
            
            Text(text)
                .font(.inter(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
        }
    }
}

//struct BrowserAuthnView_Previews: PreviewProvider {
//    static var previews: some View {
//        BrowserAuthnView()
//    }
//}
