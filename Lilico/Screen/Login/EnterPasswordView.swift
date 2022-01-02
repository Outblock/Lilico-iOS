//
//  EnterPasswordView.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI
import SwiftUIX

struct EnterPasswordView: View {
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

    @State
    var text: String = ""

    @State
    var textStatus: LL.TextField.Status = .normal

    @State
    var buttonState: VPrimaryButtonState = .disabled

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Enter")
                            .foregroundColor(Color.LL.rebackground)
                            .bold()
                        Text("Password")
                            .foregroundColor(Color.LL.orange)
                            .bold()
                    }
                    .font(.largeTitle)

                    Text("The password you created when you backup the wallet.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VTextField(model: TextFieldStyle.primary,
                           type: .secure,
//                           highlight: .error,
                           placeholder: "Enter your password",
                           footerTitle: "Enter 8 characters, with at least 1 number",
                           text: $text) {}
                    .padding(.top, 50)

                Spacer()

                VPrimaryButton(model: ButtonStyle.primary,
                               state: buttonState,
                               action: {}, title: "Continue")

//                Button {
//                    router.route(to: \.userName)
//                } label: {
//                    Text("Continue")
//                        .font(.headline)
//                        .bold()
//                        .frame(maxWidth: .infinity,alignment: .center)
//                        .padding(.vertical, 18)
//                        .foregroundColor(Color.LL.background)
//                        .background {
//                            RoundedRectangle(cornerRadius: 16)
//                                .foregroundColor(Color.LL.rebackground)
//                        }
//                }
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
        }
    }
}

struct EnterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPasswordView()
    }
}
