//
//  SettingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
    @StateObject var themeManager = ThemeManager.shared
    @StateObject private var vm: ProfileViewModel = ProfileViewModel()
    @EnvironmentObject private var router: ProfileCoordinator.Router
    @StateObject private var lud = LocalUserDefaults.shared
    @StateObject private var userManager = UserManager.shared
    
    init() {
//        UITableView.appearance().sectionFooterHeight = .leastNormalMagnitude
//        UITableView.appearance().sectionHeaderHeight = .leastNormalMagnitude
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            List {
                if userManager.isLoggedIn {
                    InfoContainerView()
                    ActionSectionView()
                } else {
                    NoLoginTipsView()
                }
                
                GeneralSectionView()
                AboutSectionView()
                
                if vm.state.isLogin {
                    MoreSectionView()
                }
            }
            .background(.LL.Neutrals.background)
            .buttonStyle(.plain)
        }
        .preferredColorScheme(themeManager.style)
        .backgroundFill(.LL.Neutrals.background)
        .environmentObject(vm)
        .environmentObject(lud)
        .environmentObject(userManager)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
//        ProfileView.NoLoginTipsView()
//        ProfileView.GeneralSectionView()
        let model = ProfileView.ProfileViewModel()
        ProfileView().environmentObject(model)
//        ProfileView.InfoView()
//        ProfileView.InfoActionView()
    }
}

// MARK: - Section login tips

extension ProfileView {
    struct NoLoginTipsView: View {
        private let title = "welcome_to_lilico".localized
        private let desc = "welcome_desc".localized
        
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
        @EnvironmentObject private var userManager: UserManager
        @EnvironmentObject private var router: ProfileCoordinator.Router
        
        var body: some View {
            HStack(spacing: 16) {
                KFImage.url(URL(string: userManager.userInfo?.avatar.convertedAvatarString() ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 82, height: 82)
                    .background(.LL.Primary.salmonPrimary)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(userManager.userInfo?.nickname ?? "").foregroundColor(.LL.Neutrals.text).font(.inter(weight: .semibold))
                    Text("@\(userManager.userInfo?.username ?? "")").foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    router.route(to: \.edit)
                } label: {
                    Image("icon-profile-edit")
                }
                .frame(size: CGSize(width: 36, height: 36))
                .roundedButtonStyle()
            }
        }
    }
    
    struct InfoActionView: View {
        @EnvironmentObject private var router: ProfileCoordinator.Router
        
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ProfileView.InfoActionButton(iconName: "icon-address", title: "addresses".localized) {
                    router.route(to: \.addressBook)
                }

                ProfileView.InfoActionButton(iconName: "icon-wallet", title: "wallets".localized) {
                    print("wallets click")
                }

                ProfileView.InfoActionButton(iconName: "icon-device", title: "device".localized) {
                    print("device click")
                }
            }
            .padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondarySystemGroupedBackground))
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
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
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
            return "backup".localized
        case .security:
            return "security".localized
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
            return "manually".localized
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
        @EnvironmentObject private var vm: ProfileViewModel
        @EnvironmentObject var router: ProfileCoordinator.Router
        
        enum Row: CaseIterable {
            case currency
            case theme
            case notification
        }
        
        var body: some View {
            Section {
                ForEach(Row.allCases, id: \.self) { row in
                    ProfileView.SettingItemCell(iconName: row.iconName, title: row.title, style: row.style, desc: row.desc(with: vm), toggle: row.toggle)
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
            return "currency".localized
        case .theme:
            return "theme".localized
        case .notification:
            return "notifications".localized
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
    
    func desc(with vm: ProfileView.ProfileViewModel) -> String {
        switch self {
        case .currency:
            return "USD"
        case .theme:
            return vm.state.colorScheme?.desc ?? "auto".localized
        case .notification:
            return ""
        }
    }
}

// MARK: - About setting

extension ProfileView {
    struct AboutSectionView: View {
        @EnvironmentObject var router: ProfileCoordinator.Router
        @EnvironmentObject var lud: LocalUserDefaults
        
        enum Row {
            case developerMode(LocalUserDefaults)
            case about
        }
        
        var body: some View {
            Section {
                let dm = Row.developerMode(lud)
                ProfileView.SettingItemCell(iconName: dm.iconName, title: dm.title, style: dm.style, desc: dm.desc, toggle: dm.toggle)
                    .onTapGestureOnBackground {
                        router.route(to: \.developerMode)
                    }
                
                ProfileView.SettingItemCell(iconName: Row.about.iconName, title: Row.about.title, style: Row.about.style, desc: Row.about.desc, toggle: Row.about.toggle)
                    .onTapGestureOnBackground {
                        
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
        case .developerMode:
            return "icon-developer-mode"
        }
    }
    
    var title: String {
        switch self {
        case .about:
            return "about".localized
        case .developerMode:
            return "developer_mode".localized
        }
    }
    
    var style: ProfileView.SettingItemCell.Style {
        switch self {
        case .about:
            return .arrow
        case .developerMode:
            return .desc
        }
    }
    
    var desc: String {
        switch self {
        case .about:
            return "about".localized
        case .developerMode(let lud):
            return lud.flowNetwork.rawValue
        }
    }
    
    var toggle: Bool {
        switch self {
        case .about:
            return false
        case .developerMode:
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
            return "switch_account".localized
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
