//
//  SettingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var model: ProfileViewModel
    
    init() {
//        UITableView.appearance().sectionFooterHeight = .leastNormalMagnitude
//        UITableView.appearance().sectionHeaderHeight = .leastNormalMagnitude
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            List {
                if model.isLogin {
                    InfoContainerView()
                    ActionSectionView()
                } else {
                    NoLoginTipsView()
                }
                
                GeneralSectionView()
                AboutSectionView()
                
                if model.isLogin {
                    MoreSectionView()
                }
            }
            .background(.LL.Neutrals.background)
        }
        .backgroundFill(.LL.Neutrals.background)
    }
}

class ProfileViewModel: ObservableObject {
    @Published var isLogin: Bool = false
    @Published var currency: String = "USD"
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
//        ProfileView.NoLoginTipsView()
//        ProfileView.GeneralSectionView()
        let model = ProfileViewModel()
        ProfileView().environmentObject(model)
//        ProfileView.InfoView()
//        ProfileView.InfoActionView()
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
                    }.frame(maxHeight: .infinity, alignment: .top)
                    
                    VStack(alignment: .leading) {
                        Text(title).font(.inter(size: 16, weight: .bold))
                        Text(desc).font(.inter(size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("icon-orange-right-arrow")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .roundedBg(cornerRadius: 12, strokeColor: .LL.Primary.salmonPrimary, strokeLineWidth: 1)
            }
            .listRowInsets(.zero)
            .background(.clear)
        }
    }
}

// MARK: - Section user info

extension ProfileView {
    struct InfoContainerView: View {
        var body: some View {
            Section {
                VStack(spacing: 24) {
                    ProfileView.InfoView()
                    ProfileView.InfoActionView()
                }
            }
            .listRowInsets(.zero)
            .background(.LL.Neutrals.background)
        }
    }
    
    struct InfoView: View {
        var body: some View {
            HStack(spacing: 16) {
                Image("").frame(width: 82, height: 82).background(.LL.Primary.salmonPrimary).clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("user name").foregroundColor(.LL.Neutrals.text).font(.inter(weight: .semibold))
                    Text("@test").foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    
                } label: {
                    Image("icon-profile-edit")
                }
            }
        }
    }
    
    struct InfoActionView: View {
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ProfileView.InfoActionButton(iconName: "icon-address", title: "Addresses") {
                    
                }
                
                ProfileView.InfoActionButton(iconName: "icon-wallet", title: "Wallets") {
                    
                }
                
                ProfileView.InfoActionButton(iconName: "icon-device", title: "Device") {
                    
                }
            }
            .padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 16).fill(.white))
        }
    }
    
    struct InfoActionButton: View {
        let iconName: String
        let title: String
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack {
                    Image(iconName)
                    Text(title).foregroundColor(.LL.Neutrals.note).font(.inter(size: 12, weight: .medium))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Section action setting

extension ProfileView {
    struct ActionSectionView: View {
        enum Row: CaseIterable {
            case backup
            case security
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

extension ProfileView.ActionSectionView.Row {
    var iconName: String {
        switch self {
        case .backup:
            return "icon-backup"
        case .security:
            return "icon-security"
        }
    }
    
    var title: String {
        switch self {
        case .backup:
            return "Backup"
        case .security:
            return "Security"
        }
    }
    
    var style: ProfileView.SettingItemCell.Style {
        switch self {
        case .backup:
            return .desc
        case .security:
            return .arrow
        }
    }
    
    var desc: String {
        switch self {
        case .backup:
            return "Manually"
        case .security:
            return ""
        }
    }
    
    var toggle: Bool {
        switch self {
        case .backup:
            return false
        case .security:
            return false
        }
    }
}

// MARK: - Section general setting

extension ProfileView {
    struct GeneralSectionView: View {
        @EnvironmentObject var model: ProfileViewModel
        @EnvironmentObject var router: ProfileCoordinator.Router
        
        enum Row: CaseIterable {
            case currency
            case theme
            case notification
        }
        
        var body: some View {
            Section {
                ForEach(Row.allCases, id: \.self) { row in
                    ProfileView.SettingItemCell(iconName: row.iconName, title: row.title, style: row.style, desc: row.desc, toggle: row.toggle)
                        .onTapGestureOnBackground {
                            if row == .theme {
                                router.route(to: \.themeChange)
                            }
                        }
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
            return ThemeManager.shared.style?.desc ?? "Auto"
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
                .onTapGestureOnBackground {
                    let style = ThemeManager.shared.style ?? .light
                    ThemeManager.shared.setStyle(style: style == .light ? .dark : .light)
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

// MARK: - Section more setting

extension ProfileView {
    struct MoreSectionView: View {
        enum Row: CaseIterable {
            case switchAccount
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

extension ProfileView.MoreSectionView.Row {
    var iconName: String {
        switch self {
        case .switchAccount:
            return "icon-switch-account"
        }
    }
    
    var title: String {
        switch self {
        case .switchAccount:
            return "Switch Account"
        }
    }
    
    var style: ProfileView.SettingItemCell.Style {
        switch self {
        case .switchAccount:
            return .none
        }
    }
    
    var desc: String {
        switch self {
        case .switchAccount:
            return ""
        }
    }
    
    var toggle: Bool {
        switch self {
        case .switchAccount:
            return false
        }
    }
}

// MARK: - Component

extension ProfileView {
    struct SettingItemCell: View {
        enum Style {
            case none
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
        var toggleAction: ((Bool) -> Void)? = nil
        
        var body: some View {
            HStack {
                Image(iconName)
                Text(title).font(.inter()).frame(maxWidth: .infinity, alignment: .leading)
                
                Text(desc ?? "").font(.inter()).foregroundColor(.LL.Neutrals.note).visibility(style == .desc ? .visible : .gone)
                Image("icon-black-right-arrow").visibility(style == .arrow ? .visible : .gone)
                Toggle(isOn: $toggle) {
                    
                }
                .tint(.LL.Primary.salmonPrimary)
                .visibility(style == .toggle ? .visible : .gone)
                .onChange(of: toggle) { value in
                    if let action = toggleAction {
                        action(value)
                    }
                }
                
                if let imageName = imageName, style == .image {
                    Image(imageName)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
        }
    }
}
