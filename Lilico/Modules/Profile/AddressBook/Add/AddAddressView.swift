//
//  AddAddressView.swift
//  Lilico
//
//  Created by Selina on 1/6/2022.
//

import SwiftUI

struct AddAddressView: View {
    @EnvironmentObject private var router: AddressBookCoordinator.Router
    @StateObject var vm: AddAddressViewModel

    init() {
        _vm = StateObject(wrappedValue: AddAddressViewModel())
    }

    init(editingContact: Contact) {
        _vm = StateObject(wrappedValue: AddAddressViewModel(contact: editingContact))
    }

    var body: some View {
        BaseView {
            VStack(spacing: 30) {
                nameField
                addressField
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle(vm.state.isEditingMode ? "edit_contact".localized : "add_contact".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .navigationBarItems(trailing: HStack {
            Button {
                vm.trigger(.save)
            } label: {
                Text("save".localized)
            }
            .buttonStyle(.plain)
            .foregroundColor(.LL.Primary.salmonPrimary)
            .disabled(!vm.state.isReadyForSave)
        })
    }

    var nameField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("name".localized, text: $vm.state.name).frame(height: 50)
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)

            Text("enter_a_name".localized).foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .regular))
        }
    }

    var addressField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("address".localized, text: $vm.state.address).frame(height: 50)
                    .onChange(of: vm.state.address) { _ in
                        vm.trigger(.checkAddress)
                    }
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)

            let addressNormalView = Text("enter_address".localized)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 14, weight: .regular))

            switch vm.state.addressStateType {
            case .idle, .checking, .passed:
                addressNormalView.visibility(.visible)
            default:
                addressNormalView.visibility(.gone)
            }

            let addressErrorView =
                HStack(spacing: 5) {
                    Image(systemName: .error).foregroundColor(.red)
                    Text(vm.state.addressStateType.desc).foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .regular))
                }

            switch vm.state.addressStateType {
            case .idle, .checking, .passed:
                addressErrorView.visibility(.gone)
            default:
                addressErrorView.visibility(.visible)
            }
        }
    }
}

struct AddAddressView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddAddressView()
        }
    }
}
