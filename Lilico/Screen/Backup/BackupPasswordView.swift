//
//  BackupPasswordView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI
import SwiftUIX

extension BackupPasswordView {
    struct ViewState {
        var isLoading = false
        var username: String
    }

    enum Action {
        case secureBackup(String)
        case onPasswordChanged(String)
        case onConfirmChanged(String)
    }
}

struct BackupPasswordView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

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

    @State
    var isTick: Bool = false

    var footerText: String = "1233"

    @State
    var highlight: VTextFieldHighlight = .none

    @State
    var confrimHighlight: VTextFieldHighlight = .none

    @State
    var text: String = ""

    @State
    var nametext: String = UserManager.shared.userInfo?.username ?? "user"

    @State
    var confrimText: String = ""

    var model: VTextFieldModel = {
        var model = TextFieldStyle.primary
        model.misc.textContentType = .newPassword
        return model
    }()

    var canGoNext: Bool {
        if confrimText.count < 8 && text.count < 8 {
            return false
        }

        return confrimText == text && isTick
    }
    
    var buttonState: VPrimaryButtonState {
        if viewModel.isLoading {
            return .loading
        }
        return canGoNext ?  .enabled : .disabled
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                ZStack {
                    TextField("", text: $nametext)
                        .introspectTextField { textfield in
                            textfield.textContentType = .username
                        }
                        .opacity(0.1)
                        .offset(y: -UIScreen.main.bounds.height)
                    VStack(alignment: .leading) {
                        Text("Create Backup")
                            .bold()
                            .foregroundColor(Color.LL.text)
                            .font(.LL.largeTitle)

                        Text("Password")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                            .font(.LL.largeTitle)

                        Text("Lilico uses this password to secure your backup in cloud stroage.")
                            .font(.LL.body)
                            .foregroundColor(.LL.note)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 30)
                }

                Spacer()

                VStack(spacing: 30) {
                    VTextField(model: model,
                               type: .secure,
                               highlight: highlight,
                               placeholder: "Backup Password",
                               footerTitle: "Minimum 8 character",
                               text: $text,
                               onChange: {
                                   viewModel.trigger(.onPasswordChanged(text))
                               })

                    VTextField(model: model,
                               type: .secure,
                               highlight: confrimHighlight,
                               placeholder: "Confirm Password",
                               footerTitle: "",
                               text: $confrimText,
                               onChange: {
                        viewModel.trigger(.onConfirmChanged(confrimText))
                    },
                               onReturn: .returnAndCustom {})
                }.padding(.bottom, 30)

                VCheckBox(model: CheckBoxStyle.secondary,
                          isOn: $isTick) {
                    VText(type: .oneLine,
                          font: .footnote,
                          color: Color.LL.rebackground,
                          title: "I understand Lilico can not recover this password.")
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

                VPrimaryButton(model: ButtonStyle.primary,
                               state: buttonState,
                               action: {
                                   viewModel.trigger(.secureBackup(confrimText))
                               },
                               title: "Secure Backup"
                )
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct BackupPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        BackupPasswordView(viewModel: BackupPasswordViewModel().toAnyViewModel())
            .previewDevice("iPhone 12 mini")
            .environment(\.locale, .init(identifier: "en"))
            .colorScheme(.dark)
    }
}
