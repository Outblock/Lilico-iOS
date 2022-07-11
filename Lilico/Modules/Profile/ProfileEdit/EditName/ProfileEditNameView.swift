//
//  ProfileEditNameView.swift
//  Lilico
//
//  Created by Selina on 14/6/2022.
//

import SwiftUI

struct ProfileEditNameView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditNameView()
    }
}

struct ProfileEditNameView: View {
    @EnvironmentObject private var router: ProfileEditCoordinator.Router
    @StateObject private var vm = ProfileEditNameViewModel()

    var body: some View {
        BaseView {
            VStack(spacing: 30) {
                nameField
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationTitle("edit_nickname".localized)
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
            .disabled(vm.status != .ok)
        })
    }
}

extension ProfileEditNameView {
    var nameField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("name".localized, text: $vm.name).frame(height: 50)
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)
        }
    }
}
