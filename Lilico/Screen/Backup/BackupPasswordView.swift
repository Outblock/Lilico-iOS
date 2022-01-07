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
        //        var isLoading = false
    }

    enum Action {
        case backupSuccess
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
    var text: String = ""

    @State
    var confrimText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Create Backup")
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                        .font(.largeTitle)

                    Text("Password")
                        .bold()
                        .foregroundColor(Color.LL.orange)
                        .font(.largeTitle)

                    Text("Lilico uses this password to secure your backup in cloud stroage.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                Spacer()

                VStack(spacing: 30) {
                    VTextField(model: TextFieldStyle.primary,
                               type: .secure,
                               highlight: highlight,
                               placeholder: "Backup Password",
                               footerTitle: "",
                               text: $text,
                               onChange: {
                                   viewModel.trigger(.onPasswordChanged(text))
                               })

                    VTextField(model: TextFieldStyle.primary,
                               type: .secure,
                               highlight: highlight,
                               placeholder: "Confirm Password",
                               footerTitle: "",
                               text: $text,
                               onChange: {},
                               onReturn: .returnAndCustom {})
                }

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
                               state: .disabled,
                               action: {
                                   viewModel.trigger(.backupSuccess)
                               }, title: "Confirm Backup")
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
