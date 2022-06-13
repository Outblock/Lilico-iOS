//
//  ThemeChangeView.swift
//  Lilico
//
//  Created by Selina on 18/5/2022.
//

import Foundation
import SwiftUI

struct ThemeChangeView: View {
    @EnvironmentObject private var router: ProfileCoordinator.Router
    @StateObject private var vm: ThemeChangeViewModel = ThemeChangeViewModel()
    @StateObject var themeManager = ThemeManager.shared
    
    var body: some View {
        BaseView {
            VStack {
                themeItemView.padding(.vertical, 24)
                BaseDivider()
                autoItemView
            }
            .roundedBg()
            .padding(.horizontal, 18)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .addBackBtn {
            router.pop()
        }
        .navigationTitle("theme".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Previews_ThemeChangeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeChangeView()
    }
}

extension ThemeChangeView {
    var themeItemView: some View {
        HStack(spacing: 0) {
            ThemePreviewItemView(imageName: "preview-theme-light", title: "light".localized, isSelected: $vm.state.isLight) {
                vm.trigger(.change(.light))
            }
            
            ThemePreviewItemView(imageName: "preview-theme-dark", title: "dark".localized, isSelected: $vm.state.isDark) {
                vm.trigger(.change(.dark))
            }
        }
    }
    
    var autoItemView: some View {
        VStack {
            Toggle(isOn: $vm.state.isAuto) {
                Image(systemName: .sun).font(.system(size: 25)).foregroundColor(.LL.Secondary.mango4)
                Text("auto".localized).foregroundColor(.LL.Neutrals.text).font(.inter(size: 16, weight: .medium))
            }
            .tint(.LL.Primary.salmonPrimary)
            .onChange(of: vm.state.isAuto) { value in
                if value == true {
                    vm.trigger(.change(nil))
                } else {
                    if ThemeManager.shared.style == nil {
                        vm.trigger(.change(.light))
                    } else {
                        vm.trigger(.change(ThemeManager.shared.style))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }
}

extension ThemeChangeView {
    struct ThemePreviewItemView: View {
        let imageName: String
        let title: String
        @Binding var isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                VStack(spacing: 0) {
                    Image(imageName).padding(.bottom, 16).aspectRatio(contentMode: .fit)
                    Text(title).foregroundColor(.LL.Neutrals.text).font(.inter(size: 16, weight: .medium)).padding(.bottom, 9)
                    if isSelected {
                        Image(systemName: .checkmarkSelected).foregroundColor(.LL.Success.success2)
                    } else {
                        Image(systemName: .checkmarkUnselected).foregroundColor(.LL.Neutrals.neutrals1)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
