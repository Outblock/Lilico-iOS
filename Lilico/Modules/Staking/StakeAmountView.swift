//
//  StakeAmountView.swift
//  Lilico
//
//  Created by Selina on 17/11/2022.
//

import SwiftUI

struct StakeAmountView: RouteableView {
    @State private var inputText: String = ""
    
    var title: String {
        return "stake_amount".localized
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .large
    }
    
    var body: some View {
        VStack(spacing: 0) {
            inputContainerView
            amountPercentContainerView
            rateContainerView
            Spacer()
            stakeBtn
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
    }
    
    var inputContainerView: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("", text: $inputText)
                    .disableAutocorrection(true)
                    .modifier(PlaceholderStyle(showPlaceHolder: inputText.isEmpty,
                                               placeholder: "stake_amount_flow".localized,
                                               font: .inter(size: 14, weight: .medium),
                                               color: Color.LL.Neutrals.note))
                    .font(.inter(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: inputText) { text in
//                        withAnimation {
//                            vm.inputTextDidChangeAction(text: text)
//                        }
                    }
                
                Text("$1851.29 USD")
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            .frame(height: 53)
            
            Divider()
                .background(Color.LL.Neutrals.note)
            
            HStack {
                Image("flow")
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Text("112.29 Flow Available")
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text2)
                
                Spacer()
            }
            .frame(height: 53)
        }
        .padding(.horizontal, 18)
        .background(Color.LL.Neutrals.neutrals6)
        .cornerRadius(16)
    }
    
    var amountPercentContainerView: some View {
        VStack {
            HStack(spacing: 8) {
                Button {
                    
                } label: {
                    createAmountPercentBtn("30%")
                }
                
                Button {
                    
                } label: {
                    createAmountPercentBtn("50%")
                }
                
                Button {
                    
                } label: {
                    createAmountPercentBtn("max".localized)
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 56)
            .padding(.top, 18)
        }
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.top, -18)
        .padding(.horizontal, 4)
        .zIndex(-1)
    }
    
    func createAmountPercentBtn(_ title: String) -> some View {
        Text(title)
            .font(.inter(size: 14, weight: .bold))
            .foregroundColor(Color.LL.Primary.salmonPrimary)
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            .background {
                Color.LL.Primary.salmonPrimary
                    .opacity(0.12)
            }
            .cornerRadius(16)
    }
    
    var rateContainerView: some View {
        VStack(spacing: 0) {
            HStack {
                Text("stake_rate".localized)
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Spacer()
                
                Text("12.04%")
                    .font(.inter(size: 14, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
            }
            .frame(height: 48)
            
            Divider()
                .background(Color.LL.Neutrals.note)
            
            VStack(spacing: 0) {
                HStack {
                    Text("stake_annual_reward".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Spacer()
                    
                    Text("2000.00 Flow")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text)
                }
                .frame(height: 35)
                
                HStack {
                    Spacer()
                    
                    Text("≈ $27320.00 USD")
                        .font(.inter(size: 12, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text3)
                }
                .padding(.bottom, 12)
            }
        }
        .padding(.horizontal, 18)
        .background(Color.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.top, 12)
    }
    
    var stakeBtn: some View {
        Button {
            
        } label: {
            Text("stake".localized)
                .font(.inter(size: 16, weight: .bold))
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.LL.Primary.salmonPrimary)
                .cornerRadius(16)
        }
    }
}
