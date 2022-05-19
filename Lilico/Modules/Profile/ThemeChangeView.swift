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
    
    var body: some View {
        BaseView {
            
        }
        .addBackBtn {
            router.popLast()
        }
        .navigationTitle("Theme")
    }
}

struct Previews_ThemeChangeView_Previews: PreviewProvider {
    static var previews: some View {
//        ThemeChangeView()
        ThemeChangeView.ThemePreviewItemView(imageName: "preview-theme-light", title: "Light", isSelected: false)
    }
}

extension ThemeChangeView {
    var themeItemView: some View {
        HStack {
            
        }
    }
}

extension ThemeChangeView {
    struct ThemePreviewItemView: View {
        let imageName: String
        let title: String
        @State var isSelected: Bool = false
        
        var body: some View {
            VStack {
                Image(imageName)
                Text(title).foregroundColor(.LL.Neutrals.text).font(.inter(size: 16, weight: .medium))
                if isSelected {
                    Image(systemName: .checkmarkSelected).foregroundColor(.LL.Success.success2)
                } else {
                    Image(systemName: .checkmarkUnselected).foregroundColor(.LL.Neutrals.neutrals1)
                }
                
                Image(isSelected ? .checkmarkSelected : .checkmarkUnselected)
            }
        }
    }
}
