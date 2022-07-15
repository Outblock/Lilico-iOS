//
//  WalletSendView.swift
//  Lilico
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI
import SwiftUIPager

//struct WalletSendView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            WalletSendView()
//        }
//    }
//}

struct WalletSendView: View {
    @EnvironmentObject private var router: WalletSendCoordinator.Router
    @StateObject private var vm = WalletSendViewModel()
    @FocusState private var searchIsFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            searchBar
            
            ZStack {
                VStack(spacing: 0) {
                    switchBar
                    contentView
                }
                
                searchContainerView
                    .visibility(vm.status == .normal ? .gone : .visible)
            }
        }
        .navigationTitle("send_to".localized)
        .navigationBarTitleDisplayMode(.large)
        .interactiveDismissDisabled()
        .addBackBtn {
            router.dismissCoordinator()
        }
        .buttonStyle(.plain)
        .backgroundFill(Color.LL.deepBg)
    }
    
    var switchBar: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Button {
                        vm.changeTabTypeAction(type: .recent)
                    } label: {
                        SwitchButton(icon: "icon-recent", title: "recent".localized, isSelected: vm.tabType == .recent)
                            .contentShape(Rectangle())
                    }

                    Button {
                        vm.changeTabTypeAction(type: .addressBook)
                    } label: {
                        SwitchButton(icon: "icon-addressbook", title: "address_book".localized, isSelected: vm.tabType == .addressBook)
                            .contentShape(Rectangle())
                    }
                }
                
                // indicator
                let widthPerTab = geo.size.width / CGFloat(tabCount)
                Color.LL.Primary.salmon4
                    .frame(width: widthPerTab, height: 2)
                    .padding(.leading, widthPerTab * CGFloat(vm.tabType.rawValue))
            }
        }
        .frame(height: 70)
    }
    
    var contentView: some View {
        ZStack {
            Pager(page: vm.page, data: TabType.allCases, id: \.self) { type in
                switch type {
                case .recent:
                    recentContainerView
                case .addressBook:
                    addressBookContainerView
                }
            }
            .onPageChanged { newIndex in
                vm.changeTabTypeAction(type: TabType(rawValue: newIndex) ?? .recent)
            }
        }
    }
}

// MARK: - Search

extension WalletSendView {
    var searchBar: some View {
        HStack(spacing: 8) {
            Image("icon-search")
            TextField("", text: $vm.searchText)
                .modifier(PlaceholderStyle(showPlaceHolder: vm.searchText.isEmpty,
                                           placeholder: "send_search_placeholder".localized,
                                           font: .inter(size: 14, weight: .medium),
                                           color: Color.LL.Neutrals.neutrals6))
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onChange(of: vm.searchText) { st in
                    vm.searchTextDidChangeAction(text: st)
                }
                .onSubmit {
                    vm.searchCommitAction()
                }
                .focused($searchIsFocused)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .background(.LL.Neutrals.background)
        .cornerRadius(16)
        .padding(.horizontal, 18)
    }
    
    var searchContainerView: some View {
        VStack() {
            searchLocalView
                .visibility(vm.status == .prepareSearching ? .visible : .gone)
            
            errorMsgView
                .visibility(vm.status == .error ? .visible : .gone)
            
            searchingView
                .visibility(vm.status == .searching ? .visible : .gone)
            
            remoteSearchListView
                .visibility(vm.status == .searchResult ? .visible : .gone)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 27)
        .backgroundFill(Color.LL.deepBg)
    }
    
    var searchLocalView: some View {
        VStack(spacing: 10) {
            // tips
            Button {
                vm.searchCommitAction()
                searchIsFocused = false
            } label: {
                HStack(spacing: 0) {
                    Image("icon-add-friends")
                        .frame(width: 40, height: 40)
                        .background(.LL.bgForIcon)
                        .clipShape(Circle())
                    
                    
                    Text("search_the_id".localized)
                        .foregroundColor(.LL.Neutrals.neutrals6)
                        .font(.inter(size: 14, weight: .semibold))
                        .padding(.leading, 16)
                    
                    Text(vm.searchText)
                        .foregroundColor(.LL.Primary.salmonPrimary)
                        .font(.inter(size: 14, weight: .medium))
                        .underline()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 5)
                        .lineLimit(1)
                }
                .frame(height: 50)
                .padding(.horizontal, 18)
                .contentShape(Rectangle())
            }
            
            // local search table view
            localSearchListView
        }
    }
    
    var localSearchListView: some View {
        return VSectionList(model: searchSectionListConfig,
                            sections: vm.localSearchResults,
                            headerContent: { section in
            searchResultSectionHeader(title: section.title)
        },
                            footerContent: { section in
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 20)
        },
                            rowContent: { row in
            AddressBookView.ContactCell(contact: row)
        })
    }
    
    var searchingView: some View {
        Text("searching")
            .foregroundColor(.LL.Neutrals.note)
            .font(.inter(size: 12, weight: .medium))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var errorMsgView: some View {
        HStack(alignment: .top, spacing: 8) {
            Image("icon-info")
            Text("no_account_found_msg".localized)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 12, weight: .medium))
                .lineSpacing(10)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
    }
    
    var remoteSearchListView: some View {
        return VSectionList(model: searchSectionListConfig,
                            sections: vm.remoteSearchResults,
                            headerContent: { section in
            searchResultSectionHeader(title: section.title)
        },
                            footerContent: { section in
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 20)
        },
                            rowContent: { row in
            AddressBookView.ContactCell(contact: row, showAddBtn: !vm.addressBookVM.isFriend(contact: row)) {
                vm.addContactAction(contact: row)
            }
        })
    }
    
    var searchSectionListConfig: VSectionListModel {
        var model = VSectionListModel()
        model.layout.dividerHeight = 0
        model.layout.contentMargin = 0
        model.layout.sectionSpacing = 0
        model.layout.rowSpacing = 0
        model.layout.headerMarginBottom = 8
        model.layout.footerMarginTop = 0
        model.colors.background = Color.LL.deepBg
        
        return model
    }
    
    private func searchResultSectionHeader(title: String) -> some View {
        Text(title)
            .foregroundColor(.LL.Neutrals.note)
            .font(.inter(size: 14, weight: .medium))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 33)
    }
}

// MARK: - Recent

extension WalletSendView {
    var recentContainerView: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(vm.recentList, id: \.id) { contact in
                        AddressBookView.ContactCell(contact: contact)
                            .onTapGestureOnBackground {
                                vm.sendToTargetAction(target: contact)
                            }
                    }
                }
            }
            
            emptyView.visibility(vm.recentList.isEmpty ? .visible : .gone)
        }
        .frame(maxHeight: .infinity)
    }
    
    var emptyView: some View {
        VStack {
            Image("icon-send-empty-users")
            Text("send_user_empty".localized)
                .foregroundColor(Color.LL.note)
                .font(.inter(size: 18, weight: .semibold))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Address Book

extension WalletSendView {
    var addressBookContainerView: some View {
        ZStack {
            AddressBookView(mode: .inline, vm: vm.addressBookVM)
        }
        .frame(maxHeight: .infinity)
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
