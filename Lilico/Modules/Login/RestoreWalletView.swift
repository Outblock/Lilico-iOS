//
//  RestoreWallet.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

struct RestoreWalletView: View {
    @EnvironmentObject var router: LoginCoordinator.Router
    var viewModel: RestoreWalletViewModel

    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("restore".localized)
                        .foregroundColor(Color.LL.orange)
                        .bold()
                    Text("wallet".localized)
                        .foregroundColor(Color.LL.text)
                        .bold()
                }
                .font(.LL.largeTitle)

                Text("restore_with_words_desc".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                
            }, title: "restore_with_icloud".localized)
            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                viewModel.restoreWithGoogleDriveAction()
            }, title: "restore_with_gd".localized)
            
            VPrimaryButton(model: ButtonStyle.border,
                           action: {
                viewModel.restoreWithManualAction()
            }, title: "restore_with_recovery_phrase".localized)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
        .navigationTitle("".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.dismissCoordinator()
        }
        .backgroundFill(Color.LL.background)
    }
}

struct RestoreWalletView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWalletView(viewModel: RestoreWalletViewModel())
    }
}
