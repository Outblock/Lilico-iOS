//
//  StakeAmountView.swift
//  Lilico
//
//  Created by Selina on 17/11/2022.
//

import SwiftUI
import Kingfisher

struct StakeAmountView: RouteableView {
    @StateObject private var vm: StakeAmountViewModel
    
    init(provider: StakingProvider) {
        _vm = StateObject(wrappedValue: StakeAmountViewModel(provider: provider))
    }
    
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
            errorTipsView
            Spacer()
            stakeBtn
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .backgroundFill(.LL.deepBg)
        .halfSheet(showSheet: $vm.showConfirmView, sheetView: {
            StakeConfirmView()
                .environmentObject(vm)
        })
        .applyRouteable(self)
    }
    
    var inputContainerView: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("", text: $vm.inputText)
                    .disableAutocorrection(true)
                    .modifier(PlaceholderStyle(showPlaceHolder: vm.inputText.isEmpty,
                                               placeholder: "stake_amount_flow".localized,
                                               font: .inter(size: 14, weight: .medium),
                                               color: Color.LL.Neutrals.note))
                    .font(.inter(size: 24, weight: .bold))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: vm.inputText) { text in
                        withAnimation {
                            vm.inputTextDidChangeAction(text: text)
                        }
                    }
                
                Text(vm.inputNumAsCurrencyString)
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
                
                Text("\(vm.balance.formatCurrencyString()) \("stake_flow_available".localized)")
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
                    vm.percentAction(percent: 0.3)
                } label: {
                    createAmountPercentBtn("30%")
                }
                
                Button {
                    vm.percentAction(percent: 0.5)
                } label: {
                    createAmountPercentBtn("50%")
                }
                
                Button {
                    vm.percentAction(percent: 1.0)
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
            .foregroundColor(Color.LL.stakeMain)
            .frame(height: 32)
            .frame(maxWidth: .infinity)
            .background {
                Color.LL.stakeMain
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
                
                Text(vm.provider.apyYearPercentString)
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
                    
                    Text("\(vm.yearRewardFlowString) Flow")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text)
                }
                .frame(height: 35)
                
                HStack {
                    Spacer()
                    
                    Text("≈ \(vm.yearRewardWithCurrencyString)")
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
        VPrimaryButton(model: ButtonStyle.stakePrimary,
                       state: vm.isReadyForStake ? .enabled : .disabled,
                       action: {
            vm.stakeBtnAction()
        }, title: "next".localized)
        .padding(.bottom)
    }
    
    var errorTipsView: some View {
        HStack(spacing: 9) {
            Image(systemName: .error)
                .foregroundColor(Color(hex: "#C44536"))
            
            Text(vm.errorType.desc)
                .foregroundColor(Color(hex: "#C44536"))
                .font(.inter(size: 12, weight: .regular))
            
            Spacer()
        }
        .padding(.top, 12)
        .visibility(vm.errorType == .none ? .gone : .visible)
    }
}

extension StakeAmountView {
    struct StakeConfirmView: View {
        @EnvironmentObject var vm: StakeAmountViewModel
        
        var body: some View {
            VStack {
                SheetHeaderView(title: "stake_confirm_title".localized)
                
                VStack(spacing: 18) {
                    detailView
                    rateContainerView
                    
                    Spacer()
                    
                    confirmBtn
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
            .backgroundFill(Color.LL.deepBg)
        }
        
        var detailView: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    KFImage.url(vm.provider.iconURL)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 16, height: 16)
                        .cornerRadius(8)
                    
                    Text(vm.provider.name)
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                        .padding(.leading, 6)
                    
                    Text("staking".localized)
                        .font(.inter(size: 12, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text4)
                        .padding(.leading, 4)
                    
                    Spacer()
                }
                .frame(height: 42)
                
                Divider()
                    .background(Color.LL.Neutrals.note)
                
                HStack(spacing: 0) {
                    Text(vm.inputTextNum.formatCurrencyString(digits: 2))
                        .font(.inter(size: 24, weight: .bold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Text("Flow")
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text2)
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Text(vm.inputNumAsCurrencyStringInConfirmSheet)
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text2)
                    
                    Text(CurrencyCache.cache.currentCurrency.rawValue)
                        .font(.inter(size: 14, weight: .medium))
                        .foregroundColor(Color.LL.Neutrals.text4)
                        .padding(.leading, 4)
                }
                .frame(height: 62)
            }
            .padding(.horizontal, 18)
            .background(Color.LL.Neutrals.background)
            .cornerRadius(16)
        }
        
        var rateContainerView: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("stake_rate".localized)
                        .font(.inter(size: 14, weight: .semibold))
                        .foregroundColor(Color.LL.Neutrals.text)
                    
                    Spacer()
                    
                    Text(vm.provider.apyYearPercentString)
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
                        
                        Text("\(vm.yearRewardFlowString) Flow")
                            .font(.inter(size: 14, weight: .medium))
                            .foregroundColor(Color.LL.Neutrals.text)
                    }
                    .frame(height: 35)
                    
                    HStack {
                        Spacer()
                        
                        Text("≈ \(vm.yearRewardWithCurrencyString)")
                            .font(.inter(size: 12, weight: .medium))
                            .foregroundColor(Color.LL.Neutrals.text3)
                    }
                    .padding(.bottom, 12)
                }
            }
            .padding(.horizontal, 18)
            .background(Color.LL.Neutrals.background)
            .cornerRadius(16)
        }
        
        var confirmBtn: some View {
            VPrimaryButton(model: ButtonStyle.stakePrimary,
                           state: vm.buttonState,
                           action: {
                vm.confirmStakeAction()
            }, title: vm.buttonState == .loading ? "working_on_it".localized : "staking_confirm".localized)
            .padding(.bottom)
        }
    }
}
