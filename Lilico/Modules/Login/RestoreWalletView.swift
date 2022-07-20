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
            Spacer()
            VStack(alignment: .leading, spacing: 18) {
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
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                
            }, title: "restore_with_icloud".localized)
            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                
            }, title: "restore_with_gd".localized)
            
            VPrimaryButton(model: ButtonStyle.border,
                           action: {
                
            }, title: "restore_with_recovery_phrase".localized)
        }
        .padding(.horizontal, 30)
        .navigationTitle("".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.dismissCoordinator()
        }
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
    }
}

struct RestoreWalletView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWalletView(viewModel: RestoreWalletViewModel())
    }
}
