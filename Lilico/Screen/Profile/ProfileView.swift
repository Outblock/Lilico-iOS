//
//  SettingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import SwiftUI

struct ProfileView: View {
    init() {
//        UITableView.appearance().sectionFooterHeight = .leastNormalMagnitude
//        UITableView.appearance().sectionHeaderHeight = .leastNormalMagnitude
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        List {
            NoLoginTipsView()
            GeneralSectionView()
            AboutSectionView()
        }
        .background(.bg)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
//        ProfileView.NoLoginTipsView()
//        ProfileView.GeneralSectionView()
        ProfileView()
            
    }
}

// MARK: - Section login tips

extension ProfileView {
    struct NoLoginTipsView: View {
        private let title = "Welcome to Lilico!"
        private let desc = "Join us and unlock all brilliant & new experiences!"
        
        var body: some View {
            Section {
                HStack {
                    VStack {
                        Image("icon-cool-cat")
                    }
                    
                    VStack(alignment: .leading) {
                        Text(title).font(.inter(size: 16, weight: .bold))
                        Text(desc).font(.inter(size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("icon-orange-right-arrow")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 12).stroke(lineWidth: 1).foregroundColor(.salmon))
            }
            .listRowInsets(.zero)
            .background(.clear)
        }
    }
}

// MARK: - Section general setting

extension ProfileView {
    struct GeneralSectionView: View {
        enum Row: CaseIterable {
            case currency
            case theme
            case notification
        }
        
        var body: some View {
            Section {
                ForEach(Row.allCases, id: \.self) {
                    ProfileView.SettingItemCell(iconName: $0.iconName, title: $0.title, style: $0.style, desc: $0.desc, toggle: $0.toggle)
                }
            }
            .listRowInsets(.zero)
        }
    }
}

extension ProfileView.GeneralSectionView.Row {
    var iconName: String {
        switch self {
        case .currency:
            return "icon-currency"
        case .theme:
            return "icon-theme"
        case .notification:
            return "icon-notification"
        }
    }
    
    var title: String {
        switch self {
        case .currency:
            return "Currency"
        case .theme:
            return "Theme"
        case .notification:
            return "Notifications"
        }
    }
    
    var style: ProfileView.SettingItemCell.Style {
        switch self {
        case .currency:
            return .desc
        case .theme:
            return .desc
        case .notification:
            return .toggle
        }
    }
    
    var desc: String {
        switch self {
        case .currency:
            return "USD"
        case .theme:
            return "Light"
        case .notification:
            return ""
        }
    }
    
    var toggle: Bool {
        switch self {
        case .currency:
            return false
        case .theme:
            return false
        case .notification:
            return false
        }
    }
}

// MARK: - About setting

extension ProfileView {
    struct AboutSectionView: View {
        enum Row: CaseIterable {
            case about
        }
        
        var body: some View {
            Section {
                ForEach(Row.allCases, id: \.self) {
                    ProfileView.SettingItemCell(iconName: $0.iconName, title: $0.title, style: $0.style, desc: $0.desc, toggle: $0.toggle)
                }
            }
            .listRowInsets(.zero)
        }
    }
}

extension ProfileView.AboutSectionView.Row {
    var iconName: String {
        switch self {
        case .about:
            return "icon-about"
        }
    }
    
    var title: String {
        switch self {
        case .about:
            return "About"
        }
    }
    
    var style: ProfileView.SettingItemCell.Style {
        switch self {
        case .about:
            return .arrow
        }
    }
    
    var desc: String {
        switch self {
        case .about:
            return "About"
        }
    }
    
    var toggle: Bool {
        switch self {
        case .about:
            return false
        }
    }
}

// MARK: - Component

extension ProfileView {
    struct SettingItemCell: View {
        enum Style {
            case desc
            case arrow
            case toggle
            case image
        }
        
        let iconName: String
        let title: String
        let style: Style
        
        var desc: String? = ""
        @State var toggle: Bool = false
        var imageName: String? = ""
        
        var body: some View {
            HStack {
                Image(iconName)
                Text(title).font(.inter()).frame(maxWidth: .infinity, alignment: .leading)
                
                Text(desc ?? "").font(.inter()).foregroundColor(.note).visibility(style == .desc ? .visible : .gone)
                Image("icon-black-right-arrow").visibility(style == .arrow ? .visible : .gone)
                Toggle(isOn: $toggle) {
                    
                }
                .tint(.salmon)
                .visibility(style == .toggle ? .visible : .gone)
                
                if let imageName = imageName, style == .image {
                    Image(imageName)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
        }
    }
}
