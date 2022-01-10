//
//  EnterPasswordView.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI
import SwiftUIX

extension EnterPasswordView {
    struct ViewState {
//        var accountData: BackupManager.AccountData
    }

    enum Action {
        case signIn(String)
    }
}


struct EnterPasswordView: View {
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

    @State
    var text: String = ""

    @State
    var textStatus: LL.TextField.Status = .normal

    var buttonState: VPrimaryButtonState {
        text.count >= 8 ? .enabled : .disabled
    }

    @State
    var state: VTextFieldState = .focused

    var model: VTextFieldModel = {
        var model = TextFieldStyle.primary
        model.misc.textContentType = .password
        return model
    }()

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("Enter")
                            .foregroundColor(Color.LL.text)
                            .bold()
                        Text("Password")
                            .foregroundColor(Color.LL.orange)
                            .bold()
                    }
                    .font(.LL.largeTitle)
                    .minimumScaleFactor(0.5)

                    Text("The password you created when you backup the wallet.")
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VTextField(model: model,
                           type: .secure,
                           state: $state,
//                           highlight: .error,
                           placeholder: "Enter your password",
                           footerTitle: "Minimum 8 characters",
                           text: $text) {}
                    .padding(.top, 50)

                Spacer()

                VPrimaryButton(model: ButtonStyle.primary,
                               state: buttonState,
                               action: {
                    viewModel.trigger(.signIn(text))
                }, title: "Restore account")

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
        let viewModel = EnterPasswordViewModel(account: .init(data: "", username: "AAA"))
        EnterPasswordView(viewModel: viewModel.toAnyViewModel())
    }
}
