//
//  WalletSendView.swift
//  Lilico
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI

struct WalletSendView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletSendView()
        }
    }
}

extension WalletSendView {
    enum TabType: Int, CaseIterable {
        case recent
        case addressBook
    }
}

struct WalletSendView: View {
    @EnvironmentObject private var router: WalletCoordinator.Router
    @State var tabType: TabType = .recent
    @State var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            switchBar
        }
        .navigationTitle("send_to".localized)
        .navigationBarTitleDisplayMode(.large)
        .addBackBtn {
            router.pop()
        }
        .buttonStyle(.plain)
        .backgroundFill(Color.LL.deepBg)
    }
    
    var searchBar: some View {
        HStack(spacing: 8) {
            Image("icon-search")
            TextField("", text: $searchText)
                .modifier(PlaceholderStyle(showPlaceHolder: searchText.isEmpty,
                                           placeholder: "send_search_placeholder".localized,
                                           font: .inter(size: 14, weight: .medium),
                                           color: Color.LL.Neutrals.neutrals6))
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .background(.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.horizontal, 18)
    }
    
    var switchBar: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        self.changeTabTypeAction(type: .recent)
                    } label: {
                        SwitchButton(icon: "icon-recent", title: "recent".localized, isSelected: tabType == .recent)
                            .contentShape(Rectangle())
                    }

                    Button {
                        self.changeTabTypeAction(type: .addressBook)
                    } label: {
                        SwitchButton(icon: "icon-addressbook", title: "address_book".localized, isSelected: tabType == .addressBook)
                            .contentShape(Rectangle())
                    }
                }
                .frame(height: 70)
                
                // indicator
                let widthPerTab = geo.size.width / CGFloat(tabCount)
                Color.LL.Primary.salmon4
                    .frame(width: widthPerTab, height: 2)
                    .padding(.leading, widthPerTab * CGFloat(tabType.rawValue))
            }
        }
    }
}

// MARK: - Component

extension WalletSendView {
    struct SwitchButton: View {
        var icon: String
        var title: String
        var isSelected: Bool = false
        
        var body: some View {
            VStack(spacing: 8) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? Color.LL.Primary.salmon3 : Color.LL.Primary.salmon5)
                
                Text(title)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 10, weight: .medium))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Helper

extension WalletSendView {
    var tabCount: Int {
        return TabType.allCases.count
    }
}

// MARK: - Test

extension WalletSendView {
    func changeTabTypeAction(type: WalletSendView.TabType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.tabType = type
        }
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    var font: Font
    var color: Color

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                Text(placeholder)
                    .lineLimit(1)
                    .padding(.horizontal, 0)
                    .foregroundColor(color)
                    .font(font)
            }
            content
        }
    }
}
