//
//  StakeGuideView.swift
//  Lilico
//
//  Created by Selina on 10/11/2022.
//

import SwiftUI
import UIKit

struct StakeGuideView: RouteableView {
    
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
                
                Button {
                    
                } label: {
                    Text("stake_guide_btn_text".localized)
                        .font(.inter(size: 16, weight: .bold))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(hex: "#865CFF"))
                        .cornerRadius(16)
                }
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
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.interSemiBold(size: 14), .foregroundColor: UIColor(hex: "#865CFF")]
        return attrs
    }
    
    func numAttributedString() -> NSAttributedString {
        let boldAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.interBold(size: 18), .foregroundColor: UIColor.LL.Neutrals.text]
        let normalAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.interMedium(size: 12), .foregroundColor: UIColor.LL.Neutrals.text]
        
        let numStr = NSMutableAttributedString(string: "309.80 ", attributes: boldAttrs)
        let normalStr = NSAttributedString(string: "Flow", attributes: normalAttrs)
        
        numStr.append(normalStr)
        
        return numStr
    }
}
