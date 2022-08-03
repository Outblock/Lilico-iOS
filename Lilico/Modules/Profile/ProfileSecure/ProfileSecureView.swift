//
//  ProfileSecureView.swift
//  Lilico
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI

struct ProfileSecureView: RouteableView {
    var title: String {
        return "security".localized
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                ProfileSecureView.ItemCell(title: "reset_pin_code".localized, style: .arrow, isOn: false, toggleAction: nil)
                Divider().foregroundColor(.LL.Neutrals.background)
                ProfileSecureView.ItemCell(title: "face_id".localized, style: .toggle, isOn: false) { value in
                    
                }
            }
            .padding(.horizontal, 16)
            .roundedBg()
            
            VStack(spacing: 0) {
                ProfileSecureView.ItemCell(title: "private_key".localized, style: .arrow, isOn: false, toggleAction: nil)
                Divider().foregroundColor(.LL.Neutrals.background)
                ProfileSecureView.ItemCell(title: "recovery_phrase".localized, style: .arrow, isOn: false, toggleAction: nil)
            }
            .padding(.horizontal, 16)
            .roundedBg()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 18)
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
    }
}

extension ProfileSecureView {
    struct ItemCell: View {
        let title: String
        let style: ProfileSecureView.ItemCell.Style
        @State var isOn: Bool = false
        let toggleAction: ((Bool) -> ())?
        
        var body: some View {
            HStack(spacing: 0) {
                Text(title)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Toggle(isOn: $isOn) {
                    
                }
                .tint(.LL.Primary.salmonPrimary)
                .onChange(of: isOn) { value in
                    toggleAction?(value)
                }
                .visibility(style == .toggle ? .visible : .gone)
                
                Image("icon-black-right-arrow")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Button.color)
                    .visibility(style == .arrow ? .visible : .gone)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
        }
    }
}

extension ProfileSecureView.ItemCell {
    enum Style {
        case arrow
        case toggle
    }
}

struct Previews_ProfileSecureView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSecureView()
    }
}
