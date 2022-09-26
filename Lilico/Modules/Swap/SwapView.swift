//
//  SwapView.swift
//  Lilico
//
//  Created by Selina on 23/9/2022.
//

import SwiftUI
import Kingfisher

struct SwapView: RouteableView {
    @StateObject var vm: SwapViewModel = SwapViewModel()
    
    var title: String {
        return "swap_title".localized
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack(spacing: 12) {
                    fromView
                    toView
                }
                
                switchButton
                    .padding(.top, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 31)
        .frame(maxWidth: .infinity)
        .background(Color.LL.background)
        .applyRouteable(self)
    }
    
    var switchButton: some View {
        Button {
            
        } label: {
            Image("icon-swap-switch")
        }
    }
}

extension SwapView {
    var fromView: some View {
        VStack(spacing: 0) {
            fromInputContainerView
                .padding(.bottom, 17)
            
            fromDescContainerView
        }
        .padding(.leading, 21)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(16)
    }
    
    var fromInputContainerView: some View {
        HStack {
            // input view
            TextField("", text: $vm.inputFromText)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(showPlaceHolder: vm.inputFromText.isEmpty,
                                           placeholder: "0.00",
                                           font: .inter(size: 32, weight: .medium),
                                           color: Color.LL.Neutrals.note))
                .font(.inter(size: 32, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
                .onChange(of: vm.inputFromText) { text in
                    withAnimation {
                        vm.inputFromTextDidChangeAction(text: text)
                    }
                }
            
            Spacer()
            
            fromSelectButton
        }
    }
    
    var fromSelectButton: some View {
        Button {
            vm.selectTokenAction(isFrom: true)
        } label: {
            HStack(spacing: 0) {
                KFImage.url(vm.fromToken?.icon)
                    .placeholder({
                        Image("placeholder-swap-token")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                Text(vm.fromToken?.symbol?.uppercased() ?? "swap_select".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .padding(.leading, 4)
                
                Image("icon-arrow-bottom")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.text)
                    .padding(.leading, 8)
            }
            .frame(height: 48)
            .padding(.horizontal, 8)
            .background(Color.LL.Neutrals.neutrals4)
            .cornerRadius(16)
        }
    }
    
    var fromDescContainerView: some View {
        HStack {
            Text("$ \(vm.fromPriceAmountString)")
                .font(.inter(size: 16))
                .foregroundColor(Color.LL.Neutrals.text2)
            
            Spacer()
            
            Button {
                
            } label: {
                Text("swap_max".localized)
                    .font(.inter(size: 12, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .padding(.horizontal, 5)
                    .frame(height: 24)
                    .background(Color.LL.background)
                    .cornerRadius(12)
            }
        }
    }
}

extension SwapView {
    var toView: some View {
        HStack {
            // input view
            TextField("", text: $vm.inputToText)
                .disableAutocorrection(true)
                .modifier(PlaceholderStyle(showPlaceHolder: vm.inputToText.isEmpty,
                                           placeholder: "0.00",
                                           font: .inter(size: 32, weight: .medium),
                                           color: Color.LL.Neutrals.note))
                .font(.inter(size: 32, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
                .onChange(of: vm.inputToText) { text in
                    withAnimation {
                        vm.inputToTextDidChangeAction(text: text)
                    }
                }
            
            Spacer()
            
            toSelectButton
        }
        .padding(.leading, 21)
        .padding(.trailing, 12)
        .padding(.vertical, 12)
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(16)
    }
    
    var toSelectButton: some View {
        Button {
            vm.selectTokenAction(isFrom: false)
        } label: {
            HStack(spacing: 0) {
                KFImage.url(vm.toToken?.icon)
                    .placeholder({
                        Image("placeholder-swap-token")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                Text(vm.toToken?.symbol?.uppercased() ?? "swap_select".localized)
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .padding(.leading, 4)
                
                Image("icon-arrow-bottom")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.text)
                    .padding(.leading, 8)
            }
            .frame(height: 48)
            .padding(.horizontal, 8)
            .roundedBg(cornerRadius: 16, fillColor: Color.LL.Neutrals.neutrals4, strokeColor: Color.LL.Primary.salmonPrimary, strokeLineWidth: 1)
        }
    }
}
