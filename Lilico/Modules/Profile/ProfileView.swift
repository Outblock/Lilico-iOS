//
//  SettingView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import Kingfisher
import SwiftUI

extension ProfileView: AppTabBarPageProtocol {
    
    static func tabTag() -> AppTabType {
        return .profile
    }

    static func iconName() -> String {
        "Avatar"
    }

    static func color() -> Color {
        // When convert from color to UIColor, it will ignore dark mode color :/
        // Hence, we manually set the color here
//        return .LL.Secondary.navy3
        //        UIScreen.main.traitCollection.userInterfaceStyle == .dark ? Color(hex: "#0B59BF") :
        return Color(hex: "#579AF2")
    }
}

struct ProfileView: RouteableView {
    @StateObject private var vm = ProfileViewModel()
    @StateObject private var lud = LocalUserDefaults.shared
    @StateObject private var userManager = UserManager.shared
    
    var title: String {
        return ""
    }
    
    var isNavigationBarHidden: Bool {
        return true
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 16) {
                    if userManager.isLoggedIn {
                        InfoContainerView()
                        ActionSectionView()
                        WalletConnectView()
                    } else {
                        NoLoginTipsView()
                    }

                    GeneralSectionView()
                    AboutSectionView()

                    if vm.state.isLogin {
                        MoreSectionView()
                    }
                    
                    Text("Version \(vm.buildVersion ?? "") (\(vm.version ?? ""))")
                        .font(.inter(size: 13, weight: .regular))
                        .foregroundColor(.LL.note.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
            .background(.LL.Neutrals.background)
            .buttonStyle(.plain)
        }
        .padding(.top, 16)
        .backgroundFill(.LL.Neutrals.background)
        .environmentObject(vm)
        .environmentObject(lud)
        .environmentObject(userManager)
        .applyRouteable(self)
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
////        ProfileView.NoLoginTipsView()
////        ProfileView.GeneralSectionView()
//        let model = ProfileView.ProfileViewModel()
//        ProfileView().environmentObject(model)
////        ProfileView.InfoView()
////        ProfileView.InfoActionView()
//    }
//}

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

                    Button {
                        Router.route(to: RouteMap.Register.root(nil))
                    } label: {
                        Image("icon-orange-right-arrow")
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 16)
                .roundedBg(cornerRadius: 12, strokeColor: .LL.Primary.salmonPrimary, strokeLineWidth: 1)
            }
            .listRowInsets(.zero)
            .listRowBackground(Color.clear)
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
            .background(.LL.Neutrals.background)
        }
    }

    struct InfoView: View {
        @EnvironmentObject private var userManager: UserManager

        var body: some View {
            HStack(spacing: 16) {
                KFImage.url(URL(string: userManager.userInfo?.avatar.convertedAvatarString() ?? ""))
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 82, height: 82)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 8) {
                    Text(userManager.userInfo?.nickname ?? "").foregroundColor(.LL.Neutrals.text).font(.inter(weight: .semibold))
                    Text("@\(userManager.userInfo?.username ?? "")").foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .medium))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    Router.route(to: RouteMap.Profile.edit)
                } label: {
                    Image("icon-profile-edit")
                }
                .frame(size: CGSize(width: 36, height: 36))
                .roundedButtonStyle()
            }
        }
    }

    struct InfoActionView: View {
        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                
                ProfileView.InfoActionButton(iconName: "icon-address", title: "addresses".localized) {
                    Router.route(to: RouteMap.Profile.addressBook)
                }

                ProfileView.InfoActionButton(iconName: "icon-wallet", title: "wallets".localized) {
                    Router.route(to: RouteMap.Profile.walletSetting(true))
                }

                ProfileView.InfoActionButton(iconName: "icon-inbox", title: "inbox".localized) {
//                    HUD.present(title: "Feature coming soon")
//                    Router.route(to: RouteMap.Explore.claimDomain)
                    Router.route(to: RouteMap.Profile.inbox)
                }
            }
            .padding(.vertical, 20)
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.LL.bgForIcon))
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
        @EnvironmentObject private var vm: ProfileViewModel
        
        enum Row {
            case backup(ProfileViewModel)
            case security
        }

        var body: some View {
            VStack {
                Section {
                    
                    Button {
                        Router.route(to: RouteMap.Profile.backupChange)
                    } label: {
                        ProfileView.SettingItemCell(iconName: Row.backup(vm).iconName, title: Row.backup(vm).title, style: Row.backup(vm).style, desc: Row.backup(vm).desc, imageName: Row.backup(vm).imageName, sysImageColor: Row.backup(vm).sysImageColor)
                    }

                    Divider().background(Color.LL.Neutrals.background).padding(.horizontal, 8)
                    
                    Button {
                        vm.securityAction()
                    } label: {
                        ProfileView.SettingItemCell(iconName: Row.security.iconName, title: Row.security.title, style: Row.security.style, desc: Row.security.desc)
                    }

                }
            }
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.LL.bgForIcon))
        }
    }
}

extension ProfileView {
    struct WalletConnectView: View {
        
        enum Row {
            case walletConnect
        }
        
        var body: some View {
            VStack {
                Section {
                    Button {
                        Router.route(to: RouteMap.Profile.walletConnect)
                    } label: {
                        ProfileView.SettingItemCell(
                            iconName: Row.walletConnect.iconName,
                            title: Row.walletConnect.title,
                            style: Row.walletConnect.style,
                            desc: Row.walletConnect.desc,
                            imageName: Row.walletConnect.imageName,
                            sysImageColor: Row.walletConnect.sysImageColor)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .background(RoundedRectangle(cornerRadius: 16)
                    .fill(Color.LL.bgForIcon))
            }
        }
    }
}

extension ProfileView.WalletConnectView.Row {
    var iconName: String {
        "walletconnect"
    }
    
    var title: String {
        "walletconnect".localized
    }
    
    var style: ProfileView.SettingItemCell.Style {
        return .arrow
    }
    
    var desc: String {
        ""
    }
    
    var sysImageColor: Color {
        .clear
    }
    
    var imageName: String {
        ""
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
        case .backup(let vm):
            switch vm.state.backupFetchingState {
            case .manually:
                return .desc
            case .fetching:
                return .progress
            case .synced, .failed:
                return .sysImage
            }
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
    
    var imageName: String {
        switch self {
        case .backup(let vm):
            switch vm.state.backupFetchingState {
            case .synced:
                return .checkmarkSelected
            case .failed:
                return .warning
            default:
                return ""
            }
            
        default:
            return ""
        }
    }
    
    var sysImageColor: Color {
        switch self {
        case .backup(let vm):
            switch vm.state.backupFetchingState {
            case .synced:
                return Color.LL.Success.success2
            case .failed:
                return Color.LL.Warning.warning2
            default:
                return .clear
            }
            
        default:
            return .clear
        }
    }
}

// MARK: - Section general setting

extension ProfileView {
    struct GeneralSectionView: View {
        @EnvironmentObject private var vm: ProfileViewModel

        enum Row: CaseIterable {
            case currency
            case theme
            case notification
        }

        var body: some View {
            VStack {
                Section {
                    // Hide other option
                    ForEach([Row.theme], id: \.self) { row in
                        
                        Button {
                            switch row {
                            case .theme:
                                Router.route(to: RouteMap.Profile.themeChange)
                            case .currency:
                                Router.route(to: RouteMap.Profile.currency)
                            default:
                                break
                            }
                        } label: {
                            ProfileView.SettingItemCell(iconName: row.iconName, title: row.title, style: row.style, desc: row.desc(with: vm), toggle: row.toggle)
                                
                        }
                        
//                        if row != .notification {
//                            Divider().background(Color.LL.Neutrals.background).padding(.horizontal, 8)
//                        }
                        
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.LL.bgForIcon))
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
            return vm.state.currency
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
        @EnvironmentObject var lud: LocalUserDefaults

        enum Row {
            case developerMode(LocalUserDefaults)
            case about
        }

        var body: some View {
            VStack {
                Section {
                    let dm = Row.developerMode(lud)
                    
                    Button {
                        Router.route(to: RouteMap.Profile.developer)
                    } label: {
                        ProfileView.SettingItemCell(iconName: dm.iconName, title: dm.title, style: dm.style, desc: dm.desc, toggle: dm.toggle)
                    }
                    
                    Divider().background(Color.LL.Neutrals.background).padding(.horizontal, 8)

                    Button {
                        Router.route(to: RouteMap.Profile.about)
                    } label: {
                        ProfileView.SettingItemCell(iconName: Row.about.iconName, title: Row.about.title, style: Row.about.style, desc: Row.about.desc, toggle: Row.about.toggle)
                    }
                        
                }
            }
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.LL.bgForIcon))
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
        case let .developerMode(lud):
            return lud.flowNetwork.rawValue.capitalized
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
            VStack {
                Section {
                    ForEach(Row.allCases, id: \.self) {
                        ProfileView.SettingItemCell(iconName: $0.iconName, title: $0.title, style: $0.style, desc: $0.desc, toggle: $0.toggle)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 16)
                .fill(Color.LL.bgForIcon))
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
            case sysImage
            case progress
        }

        let iconName: String
        let title: String
        let style: Style

        var desc: String? = ""
        @State var toggle: Bool = false
        var imageName: String? = ""
        var toggleAction: ((Bool) -> Void)? = nil
        var sysImageColor: Color? = nil

        var body: some View {
            HStack {
                Image(iconName)
                Text(title).font(.inter()).frame(maxWidth: .infinity, alignment: .leading)

                Text(desc ?? "").font(.inter()).foregroundColor(.LL.Neutrals.note).visibility(style == .desc ? .visible : .gone)
                Image("icon-black-right-arrow")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Button.color)
                    .visibility(style == .arrow ? .visible : .gone)
                Toggle(isOn: $toggle) {}
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
                
                if let imageName = imageName, let sysImageColor = sysImageColor, style == .sysImage {
                    Image(systemName: imageName)
                        .foregroundColor(sysImageColor)
                }
                
                if style == .progress {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
//            .backgroundFill(Color.LL.bgForIcon)
        }
    }
}
