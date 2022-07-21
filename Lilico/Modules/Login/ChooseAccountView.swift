//
//  ChooseAccount.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

private func createFakeItem() -> BackupManager.DriveItem {
    let item = BackupManager.DriveItem()
    item.username = UUID().uuidString
    return item
}

struct ChooseAccountView: View {
    @EnvironmentObject var router: LoginCoordinator.Router
    @StateObject var vm: ChooseAccountViewModel
    
    init(driveItems: [BackupManager.DriveItem]) {
        _vm = StateObject(wrappedValue: ChooseAccountViewModel(driveItems: driveItems))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            headerView
            Spacer()
            listView
                .padding(.top, 80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
        .navigationTitle("".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .backgroundFill(Color.LL.background)
    }
    
    var headerView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("choose".localized)
                    .foregroundColor(Color.LL.text)
                    .bold()
                Text("account".localized)
                    .foregroundColor(Color.LL.orange)
                    .bold()
            }
            .font(.LL.largeTitle)

            Text("multiple_accounts_found".localized(vm.items.count))
                .font(.LL.body)
                .foregroundColor(.LL.note)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var listView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(vm.items, id: \.username) { item in
                    Button {
                        vm.restoreAccountAction(item: item)
                    } label: {
                        createAccountView(item: item)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .buttonStyle(.plain)
    }
    
    func createAccountView(item: BackupManager.DriveItem) -> some View {
        ZStack {
            Text(item.username)
                .font(.inter(size: 14, weight: .bold))
                .foregroundColor(.LL.Neutrals.text)
                .lineLimit(1)
                .padding(.horizontal, 35)
            
            HStack {
                Spacer()
                Image("icon-account-arrow-right")
                    .renderingMode(.template)
                    .foregroundColor(.LL.Neutrals.text)
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
        .background(.LL.Neutrals.outline)
        .cornerRadius(16)
    }
}

struct ChooseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseAccountView(driveItems: [])
    }
}
