//
//  ThemeChangeView.swift
//  Lilico
//
//  Created by Selina on 18/5/2022.
//

import Foundation
import SwiftUI

struct ThemeChangeView: View {
    @EnvironmentObject var router: ProfileCoordinator.Router
    @ObservedObject var vm: ThemeChangeViewModel = ThemeChangeViewModel()
    
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
            router.popLast()
        }
        .navigationTitle("Theme")
    }
}

struct Previews_ThemeChangeView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeChangeView()
    }
}

// MARK: - ViewModel

extension ThemeChangeView {
    @MainActor class ThemeChangeViewModel: ObservableObject {
        @Published var isAuto: Bool
        @Published var isLight: Bool
        @Published var isDark: Bool
        
        func changeStyle(newStyle: ColorScheme?) {
            ThemeManager.shared.setStyle(style: newStyle)
            reloadStates()
        }
        
        private func reloadStates() {
            isAuto = ThemeManager.shared.style == nil
            isLight = ThemeManager.shared.style == .light
            isDark = ThemeManager.shared.style == .dark
            
        }
        
        init() {
            isAuto = ThemeManager.shared.style == nil
            isLight = ThemeManager.shared.style == .light
            isDark = ThemeManager.shared.style == .dark
        }
    }
}

extension ThemeChangeView {
    var themeItemView: some View {
        HStack(spacing: 0) {
            ThemePreviewItemView(imageName: "preview-theme-light", title: "Light", isSelected: $vm.isLight) {
                vm.changeStyle(newStyle: .light)
            }
            
            ThemePreviewItemView(imageName: "preview-theme-dark", title: "Dark", isSelected: $vm.isDark) {
                vm.changeStyle(newStyle: .dark)
            }
        }
    }
    
    var autoItemView: some View {
        VStack {
            Toggle(isOn: $vm.isAuto) {
                Image(systemName: .sun).font(.system(size: 25)).foregroundColor(.LL.Secondary.mango4)
                Text("Auto").foregroundColor(.LL.Neutrals.text).font(.inter(size: 16, weight: .medium))
            }
            .tint(.LL.Primary.salmonPrimary)
            .onChange(of: vm.isAuto) { value in
                if value == true {
                    vm.changeStyle(newStyle: nil)
                } else {
                    if ThemeManager.shared.style == nil {
                        vm.changeStyle(newStyle: .light)
                    } else {
                        vm.changeStyle(newStyle: ThemeManager.shared.style)
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
