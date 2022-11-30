//
//  StakeGuideView.swift
//  Lilico
//
//  Created by Selina on 10/11/2022.
//

import SwiftUI
import UIKit

class StakeGuideViewModel: ObservableObject {
    @Published var isRequesting: Bool = false
    
    var buttonState: VPrimaryButtonState {
        if isRequesting {
            return .loading
        }
        return .enabled
    }
    
    func goNext() {
        if isRequesting {
            return
        }
        
        isRequesting = true
        
        let failureBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "request_failed".localized)
            }
        }
        
        Task {
            do {
                // check staking is enabled
                if try await FlowNetwork.stakingIsEnabled() == false {
                    DispatchQueue.main.async {
                        self.isRequesting = false
                        HUD.error(title: "staking_disabled".localized)
                    }
                    return
                }
                
                // check account staking is setup
                if try await FlowNetwork.accountStakingIsSetup() == false {
                    debugPrint("StakeGuideViewModel: account staking not setup, setup right now.")
                    
                    if try await FlowNetwork.setupAccountStaking() == false {
                        debugPrint("StakeGuideViewModel: setup account staking failed.")
                        failureBlock()
                        return
                    }
                }
                
                // create delegator id
                guard let lilicoProvider = StakingProviderCache.cache.providers.first(where: { $0.isLilico }) else {
                    debugPrint("StakeGuideViewModel: can not find lilico provider.")
                    failureBlock()
                    return
                }
                
                if try await FlowNetwork.createDelegatorId(providerId: lilicoProvider.id) == false {
                    debugPrint("StakeGuideViewModel: createDelegatorId failed.")
                    failureBlock()
                    return
                }
                
                debugPrint("StakeGuideViewModel: delegator id created.")
                DispatchQueue.main.async {
                    HUD.success(title: "yes")
                    self.isRequesting = false
                }
            } catch {
                debugPrint("StakeGuideViewModel: catch error \(error)")
                failureBlock()
            }
        }
    }
}

struct StakeGuideView: RouteableView {
    @StateObject private var vm = StakeGuideViewModel()
    
    var title: String {
        return "stake_flow".localized
    }
    
    var navigationBarTitleDisplayMode: NavigationBarItem.TitleDisplayMode {
        return .large
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                topTitleView
                descView
                    .padding(.top, 50)
                
                Spacer()
                
                VPrimaryButton(model: ButtonStyle.stakePrimary,
                               state: vm.buttonState,
                               action: {
                    vm.goNext()
                }, title: vm.buttonState == .loading ? "working_on_it".localized : "stake_guide_btn_text".localized)
                .padding(.bottom)
            }
            .padding(.top, 32)
            .padding(.bottom, 20)
            .padding(.horizontal, 18)
            .background {
                Color.LL.background
                    .cornerRadius(24, corners: [.topLeft, .topRight])
            }
        }
        .padding(.top, 12)
        .backgroundFill(.LL.deepBg)
        .applyRouteable(self)
    }
    
    var topTitleView: some View {
        VStack {
            HStack {
                Image("icon-stake-ad-crown")
                
                Text("stake_ad_title_2".localized)
                    .font(.inter(size: 20, weight: .bold))
                    .foregroundColor(Color.clear)
                    .background {
                        Rectangle()
                            .fill(.linearGradient(colors: [Color(hex: "#FFC062"), Color(hex: "#0BD3FF")], startPoint: .leading, endPoint: .trailing))
                            .mask {
                                Text("stake_ad_title_2".localized)
                                    .font(.inter(size: 20, weight: .bold))
                                    .foregroundColor(Color.black)
                            }
                    }
                
                Text("stake_guide_text_1".localized)
                    .font(.inter(size: 20, weight: .bold))
                    .foregroundColor(Color.LL.Neutrals.text)
            }
            
            Text("stake_guide_text_2".localized)
                .font(.inter(size: 20, weight: .bold))
                .foregroundColor(Color.LL.Neutrals.text)
        }
    }
    
    var descView: some View {
        VStack(spacing: 25) {
            createDescSubview(icon: "icon-stake-guide-desc1", attributedString: descString1)
            createDescSubview(icon: "icon-stake-guide-desc2", attributedString: descString2)
            createDescSubview(icon: "icon-stake-guide-desc3", attributedString: descString3)
            createDescSubview(icon: "icon-stake-guide-desc4", attributedString: descString4)
        }
        .padding(.horizontal, 10)
    }
    
    func createDescSubview(icon: String, attributedString: NSAttributedString) -> some View {
        HStack {
            Image(icon)
            Text(AttributedString(attributedString))
            Spacer()
        }
    }
    
    var descString1: NSAttributedString {
        let s1 = NSMutableAttributedString(string: "stake_guide_desc_1_1".localized, attributes: descNormalAttr)
        let s2 = NSAttributedString(string: "stake_guide_desc_1_2".localized, attributes: descHighlightAttr)
        let s3 = NSMutableAttributedString(string: "stake_guide_desc_1_3".localized, attributes: descNormalAttr)
        s1.append(s2)
        s1.append(s3)
        return s1
    }
    
    var descString2: NSAttributedString {
        let s1 = NSMutableAttributedString(string: "stake_guide_desc_2_1".localized, attributes: descNormalAttr)
        let s2 = NSMutableAttributedString(string: "stake_guide_desc_2_2".localized, attributes: descHighlightAttr)
        let s3 = NSMutableAttributedString(string: "stake_guide_desc_2_3".localized, attributes: descNormalAttr)
        let s4 = NSMutableAttributedString(string: "stake_guide_desc_2_4".localized, attributes: descHighlightAttr)
        let s5 = NSMutableAttributedString(string: "stake_guide_desc_2_5".localized, attributes: descNormalAttr)
        let s6 = NSMutableAttributedString(string: "stake_guide_desc_2_6".localized, attributes: descNormalAttr)
        let s7 = NSMutableAttributedString(string: "stake_guide_desc_2_7".localized, attributes: descHighlightAttr)
        let s8 = NSMutableAttributedString(string: "stake_guide_desc_2_8".localized, attributes: descNormalAttr)
        s1.append(s2)
        s1.append(s3)
        s1.append(s4)
        s1.append(s5)
        s1.append(s6)
        s1.append(s7)
        s1.append(s8)
        return s1
    }
    
    var descString3: NSAttributedString {
        let s1 = NSMutableAttributedString(string: "stake_guide_desc_3_1".localized, attributes: descNormalAttr)
        let s2 = NSAttributedString(string: "stake_guide_desc_3_2".localized, attributes: descHighlightAttr)
        let s3 = NSMutableAttributedString(string: "stake_guide_desc_3_3".localized, attributes: descNormalAttr)
        s1.append(s2)
        s1.append(s3)
        return s1
    }
    
    var descString4: NSAttributedString {
        let s1 = NSMutableAttributedString(string: "stake_guide_desc_4_1".localized, attributes: descNormalAttr)
        let s2 = NSAttributedString(string: "stake_guide_desc_4_2".localized, attributes: descNormalAttr)
        let s3 = NSMutableAttributedString(string: "stake_guide_desc_4_3".localized, attributes: descHighlightAttr)
        let s4 = NSMutableAttributedString(string: "stake_guide_desc_4_4".localized, attributes: descNormalAttr)
        s1.append(s2)
        s1.append(s3)
        s1.append(s4)
        return s1
    }
    
    var descNormalAttr: [NSAttributedString.Key: Any] {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.interSemiBold(size: 14), .foregroundColor: UIColor.LL.Neutrals.text3]
        return attrs
    }
    
    var descHighlightAttr: [NSAttributedString.Key: Any] {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.interSemiBold(size: 14), .foregroundColor: UIColor.LL.stakeMain]
        return attrs
    }
}
