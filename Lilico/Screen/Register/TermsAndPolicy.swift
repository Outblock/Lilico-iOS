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
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Legal")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                    Text("Information")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    Text("Please review the Privacy Policy and Terms of Service of Lilico.")
                        .font(.body)
                        .bold()
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VStack(alignment: .leading) {
                    Link(destination: URL(string: "https://outblock.github.io/lilico.app/privacy-policy.html")!) {
                        Text("Terms of Service")
                            .font(.callout)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.caption2.weight(.bold))
                    }.padding()

//                    Rectangle().frame(width: .infinity, height: 1)
                    Divider().foregroundColor(Color.LL.rebackground.opacity(0.5))

                    Link(destination: URL(string: "https://outblock.github.io/lilico.app/privacy-policy.html")!) {
                        Text("Privacy Policy")
                            .font(.callout)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(Font.caption2.weight(.bold))
                    }.padding()

                }.foregroundColor(Color.LL.rebackground)

                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.LL.rebackground.opacity(0.5),
                                    lineWidth: 0.5)
                    )
                    .padding(.bottom)

                VPrimaryButton(model: ButtonStyle.primary,
                               action: {
                                   router.route(to: \.username)
                               }, title: "I Accept")
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct TermsAndPolicy_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndPolicy()
    }
}
