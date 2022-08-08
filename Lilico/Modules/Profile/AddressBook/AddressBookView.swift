//
//  AddressBookView.swift
//  Lilico
//
//  Created by Selina on 24/5/2022.
//

import SwiftUI
import Kingfisher

// struct AddressBookView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView.NoLoginTipsView()
//        ProfileView.GeneralSectionView()
//        AddressBookView()
//        ProfileView.InfoView()
//        ProfileView.InfoActionView()
//        let contacts = [
//            Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
//            Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
//            Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
//            Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel")
//        ]
//    }
// }

extension AddressBookView {
    enum Mode {
        case normal
        case inline
    }
}

struct AddressBookView: RouteableView {
    @StateObject private var vm: AddressBookViewModel

    @StateObject private var pendingDeleteModel = PendingDeleteModel()
    @State private var showAlert = false
    
    @State private var mode: Mode
    @State private var opacity: Double = 0
    
    var title: String {
        return "address_book".localized
    }
    
    init() {
        self.init(mode: .normal)
    }
    
    init(mode: Mode, vm: AddressBookViewModel? = nil) {
        self.mode = mode
        
        if let vm = vm {
            _vm = StateObject(wrappedValue: vm)
        } else {
            _vm = StateObject(wrappedValue: AddressBookViewModel())
        }
    }

    var body: some View {
        let view =
        ZStack {
            listView
            loadingView
            errorView
        }
        
        if mode == .normal {
            return AnyView(view
                .applyRouteable(self)
                .navigationBarItems(trailing: HStack(spacing: 20) {
                    Button {
                        Router.route(to: RouteMap.AddressBook.add(vm))
                    } label: {
                        Image("btn-add")
                    }
                    
                    Button {
                        debugPrint("scan btn click")
                    } label: {
                        Image("btn-scan")
                    }
                })
                .alert("contact_delete_alert".localized, isPresented: $showAlert) {
                    Button("delete".localized, role: .destructive) {
                        if let sectionVM = self.pendingDeleteModel.sectionVM, let contact = self.pendingDeleteModel.contact {
                            self.vm.trigger(.delete(sectionVM, contact))
                        }
                    }
                }
                .opacity(opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            opacity = 1
                        }
                    }
                }
            )
        }
        
        return AnyView(view)
    }
}

extension AddressBookView {
    var loadingView: some View {
        VStack {
            Text("loading".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.LL.Neutrals.background)
        .visibility(vm.state.stateType == .loading ? .visible : .gone)
    }

    var errorView: some View {
        VStack {
            Text("address_book_request_failed".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.LL.Neutrals.background)
        .visibility(vm.state.stateType == .error ? .visible : .gone)
    }

    var listView: some View {
        let list =
        
        IndexedList(vm.searchResults) { sectionVM in
            Section {
                ForEach(sectionVM.state.list) { row in
                    let cell =
                    ContactCell(contact: row)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.zero)
                        .onTapGestureOnBackground {
                            vm.trigger(.select(row))
                        }
                    
                    if mode == .normal {
                        cell.swipeActions(allowsFullSwipe: false) {
                            Button(action: {
                                self.pendingDeleteModel.sectionVM = sectionVM
                                self.pendingDeleteModel.contact = row
                                self.showAlert = true
                            }, label: {
                                Text("delete".localized)
                            })
                            .tint(Color.systemRed)
                            
                            Button(action: {
                                self.vm.trigger(.edit(row))
                            }, label: {
                                Text("edit".localized)
                            })
                        }
                    } else {
                        cell
                    }
                }
            } header: {
                sectionHeader(sectionVM)
                    .id(sectionVM.id)
            }
            .listRowBackground(Color.LL.deepBg)
        }
        .frame(maxHeight: .infinity)
        .listStyle(.plain)
        .visibility(vm.state.stateType == .idle ? .visible : .gone)
        
        var anyView: AnyView
        if mode == .normal {
            anyView = AnyView(list.searchable(text: $vm.searchText))
        } else {
            anyView = AnyView(list)
        }
        
#if compiler(>=5.7)
        if #available(iOS 16.0, *) {
            return anyView.scrollContentBackground(.hidden)
        } else {
            return anyView
        }
#else
        return anyView
#endif
    }

    @ViewBuilder private func sectionHeader(_ sectionVM: SectionViewModel) -> some View {
        let sectionName = sectionVM.state.sectionName
        Text(sectionName == "#" ? "\(sectionName)" : "#\(sectionName)").foregroundColor(.LL.Neutrals.neutrals8).font(.inter(size: 18, weight: .semibold))
    }
}

// MARK: - Component

extension AddressBookView {
    struct ContactCell: View {
        let contact: Contact
        var showAddBtn: Bool? = false
        var addAction: (() -> Void)? = nil

        var body: some View {
            HStack {
                // avatar
                ZStack {
                    if let avatar = contact.avatar?.convertedAvatarString(), avatar.isEmpty == false {
                        KFImage.url(URL(string: avatar))
                            .placeholder({
                                Image("placeholder")
                                    .resizable()
                            })
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                    } else if contact.needShowLocalAvatar {
                        Image(contact.localAvatar ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                    } else {
                        Text(String((contact.contactName?.first ?? "A").uppercased()))
                            .foregroundColor(.LL.Primary.salmonPrimary)
                            .font(.inter(size: 24, weight: .semibold))
                    }
                }
                .frame(width: 48, height: 48)
                .background(.LL.Primary.salmon5)
                .clipShape(Circle())

                // text
                VStack(alignment: .leading, spacing: 3) {
                    Text(contact.contactName ?? "no name")
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 14, weight: .bold))

                    if let userName = contact.username, !userName.isEmpty {
                        Text("@\(userName)")
                            .foregroundColor(.LL.Neutrals.note)
                            .font(.inter(size: 14, weight: .medium))
                    }

                    Text(contact.address ?? "no address")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 12, weight: .regular))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    addAction?()
                } label: {
                    Image("icon-add-friends")
                }
                .visibility(showAddBtn ?? false ? .visible : .gone)

            }
            .padding(EdgeInsets(top: 10, leading: 34, bottom: 10, trailing: 34))
        }
    }
}

extension AddressBookView {
    class PendingDeleteModel: ObservableObject {
        var sectionVM: SectionViewModel?
        var contact: Contact?
    }
}
