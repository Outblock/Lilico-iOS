//
//  RestoreWallet.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

struct RestoreWalletView: View {
    @EnvironmentObject
    var router: LoginCoordinator.Router

    var viewModel: RestoreWalletViewModel

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

    var body: some View {
        NavigationView {
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

                Button {
                    viewModel.getKeyFromiCloud()
                } label: {
                    Text("restore_with_icloud".localized)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 18)
                        .foregroundColor(Color.LL.background)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .foregroundColor(Color.LL.rebackground)
                        }
                }

                Button {
                    viewModel.signInButtonTapped()
                } label: {
                    Text("restore_with_gd".localized)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 18)
                        .foregroundColor(Color.LL.rebackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(lineWidth: 1)
                                .foregroundColor(Color.LL.rebackground)
                        }
                }

                Button {
                    router.route(to: \.inputMnemonic)
                } label: {
                    Text("restore_with_recovery_phrase".localized)
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 18)
                        .foregroundColor(Color.LL.rebackground)
//                        .background {
//                            RoundedRectangle(cornerRadius: 16)
//                                .foregroundColor(Color.LL.rebackground)
//                        }
                }
                .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }.task {
            viewModel.restoreSignIn()
        }
    }
}

struct RestoreWalletView_Previews: PreviewProvider {
    static var previews: some View {
        RestoreWalletView(viewModel: RestoreWalletViewModel())
    }
}
