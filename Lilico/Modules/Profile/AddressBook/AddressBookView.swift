//
//  AddressBookView.swift
//  Lilico
//
//  Created by Selina on 24/5/2022.
//

import SwiftUI

//struct AddressBookView_Previews: PreviewProvider {
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
//}

struct AddressBookView: View {
    @EnvironmentObject private var router: AddressBookCoordinator.Router
    @StateObject private var vm = AddressBookViewModel()
    
    @StateObject private var pendingDeleteModel: PendingDeleteModel = PendingDeleteModel()
    @State private var showAlert = false
    
    var body: some View {
        BaseView {
            ZStack {
                listView
                loadingView
                errorView
            }
        }
        .navigationTitle("address_book".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack(spacing: 20) {
            Button {
                router.route(to: \.add)
            } label: {
                Image("btn-add")
            }

            Button {
                debugPrint("scan btn click")
            } label: {
                Image("btn-scan")
            }
        })
        .addBackBtn {
            router.dismissCoordinator()
        }
        .onAppear {
            router.coordinator.addressBookVM = vm
        }
        .toast(isPresented: $vm.state.hudStatus) {
            ToastView("deleting".localized).toastViewStyle(.indeterminate)
        }
        .alert("contact_delete_alert".localized, isPresented: $showAlert) {
            Button("delete".localized, role: .destructive) {
                if let sectionVM = self.pendingDeleteModel.sectionVM, let contact = self.pendingDeleteModel.contact {
                    self.vm.trigger(.delete(sectionVM, contact))
                }
            }
        }
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
        IndexedList(vm.searchResults) { sectionVM in
            Section {
                ForEach(sectionVM.state.list) { row in
                    ContactCell(contact: row)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.zero)
                        .background(.LL.Neutrals.background)
                        .swipeActions(allowsFullSwipe: false) {
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
                }
            } header: {
                sectionHeader(sectionVM)
                    .id(sectionVM.id)
            }
        }
        .frame(maxHeight: .infinity)
        .listStyle(.plain)
        .background(.LL.Neutrals.background)
        .searchable(text: $vm.searchText)
        .visibility(vm.state.stateType == .idle ? .visible : .gone)
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
        
        var body: some View {
            HStack {
                // avatar
                ZStack {
                    if let avatar = contact.avatar, avatar.isEmpty == false {
                        Image(avatar).aspectRatio(contentMode: .fill)
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
