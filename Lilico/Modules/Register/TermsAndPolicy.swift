//
//  TermsAndPolicy.swift
//  Lilico
//
//  Created by Hao Fu on 24/12/21.
//

import SwiftUI
import WalletCore

struct TermsAndPolicy: View {
    @EnvironmentObject
    var router: RegisterCoordinator.Router

    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    var btnBack: some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
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
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("legal".localized)
                        .font(.LL.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                    Text("information".localized)
                        .font(.LL.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    Text("review_policy_tips".localized)
                        .lineSpacing(5)
                        .font(.LL.body)
                        .foregroundColor(Color.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VStack(alignment: .leading) {
                    Link(destination: URL(string: "https://outblock.github.io/lilico.app/privacy-policy.html")!) {
                        Text("terms_of_service".localized)
                            .fontWeight(.semibold)
                            .font(.LL.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.caption2.weight(.bold))
                    }.padding()

                    Divider().foregroundColor(Color.LL.outline)

                    Link(destination: URL(string: "https://outblock.github.io/lilico.app/privacy-policy.html")!) {
                        Text("privacy_policy".localized)
                            .font(.LL.body)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.caption2.weight(.bold))
                    }.padding()
                }
                .foregroundColor(Color.LL.text)

                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.LL.outline,
                                lineWidth: 1)
                )
                .padding(.bottom, 40)

                VPrimaryButton(model: ButtonStyle.primary,
                               action: {
                    router.route(to: \.username)
                }, title: "i_accept".localized)
                    .padding(.bottom)
            }
            .padding(.horizontal, 28)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct TermsAndPolicy_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndPolicy()
        TermsAndPolicy().colorScheme(.dark)
    }
}
