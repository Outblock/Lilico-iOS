//
//  ChooseAccount.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

extension ChooseAccountView {
    struct ViewState {
        var dataSource: [BackupManager.AccountData]
    }

    enum Action {
        case selectAccount(Int)
    }
}


struct ChooseAccountView: View {
    @EnvironmentObject
    var router: RegisterCoordinator.Router

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>
    
    var btnBack: some View {
        Button {
            router.dismissCoordinator()
        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }

    var model: VPrimaryButtonModel = {
        var model = ButtonStyle.primary
        model.colors.background = .init(enabled: .LL.outline,
                                        pressed: .LL.outline,
                                        loading: .LL.outline,
                                        disabled: .LL.outline)
        return model
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Choose")
                                .foregroundColor(Color.LL.text)
                                .bold()
                            Text("Account")
                                .foregroundColor(Color.LL.orange)
                                .bold()
                        }
                        .font(.LL.largeTitle)

                        Text("Multiple Accounts found.")
                            .font(.LL.body)
                            .bold()
                            .foregroundColor(.LL.note)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)

                    Spacer()

                    EnumeratedForEach(viewModel.dataSource) { index, account in
                        
                        VPrimaryButton(model: model,
                                       state: .enabled) {
                            viewModel.trigger(.selectAccount(index))
                        } content: {
                            HStack {
                                Text(account.username)
                                    .font(.LL.body)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)

                                Image(systemName: "chevron.right")
                                    .padding(.trailing)
                            }
                            .padding(.vertical, 18)
                            .foregroundColor(Color.LL.rebackground)
                        }
                        
                    }
                }
            }
            .onAppear {
                overrideNavigationAppearance()
            }
            .padding(.horizontal, 28)
            .navigationBarTitle("Choose Account", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct ChooseAccountView_Previews: PreviewProvider {
    static var previews: some View {
        let mockAccountList: [BackupManager.AccountData] = [
            .init(data: "", username: "AAAA"),
            .init(data: "", username: "BBBB"),
            .init(data: "", username: "CCCC"),
        ]
        let viewModel = ChooseAccountViewModel(accountList: mockAccountList)
        ChooseAccountView(viewModel: viewModel.toAnyViewModel())
    }
}
