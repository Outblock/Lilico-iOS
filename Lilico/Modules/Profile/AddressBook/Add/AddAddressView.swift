//
//  AddAddressView.swift
//  Lilico
//
//  Created by Selina on 1/6/2022.
//

import SwiftUI

struct AddAddressView: View {
    @EnvironmentObject private var router: AddressBookCoordinator.Router
    @StateObject var vm: AddAddressViewModel = AddAddressViewModel()
    
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
        .navigationTitle("Add address")
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .navigationBarItems(trailing: HStack {
            Button {
                debugPrint("save btn click")
            } label: {
                Text("Save")
            }
            .buttonStyle(.plain)
            .foregroundColor(.LL.Primary.salmon1)
            .disabled(!vm.state.isReadyForSave)
        })
    }
    
    var nameField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("Name", text: $vm.state.name).frame(height: 50)
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)
            
            Text("Please enter a name").foregroundColor(.LL.Neutrals.text).font(.inter(size: 14, weight: .regular))
        }
    }
    
    var addressField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("Address", text: $vm.state.address).frame(height: 50)
                    .onChange(of: vm.state.address) { _ in
                        vm.trigger(.checkAddress)
                    }
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)
            
            let addressNormalView = Text("Please enter address")
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
