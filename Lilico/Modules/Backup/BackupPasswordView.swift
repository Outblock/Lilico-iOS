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
        var backupType: BackupManager.BackupType
        var isLoading = false
        var uid: String
    }

    enum Action {
        case secureBackup(String)
        case onPasswordChanged(String)
        case onConfirmChanged(String)
    }
}

struct BackupPasswordView: View {
    @EnvironmentObject var router: BackupCoordinator.Router
    @StateObject var viewModel: AnyViewModel<ViewState, Action>
    @State var isTick: Bool = false
    @State var highlight: VTextFieldHighlight = .none
    @State var confrimHighlight: VTextFieldHighlight = .none
    @State var text: String = ""
    @State var confrimText: String = ""

    var model: VTextFieldModel = {
        var model = TextFieldStyle.primary
        model.misc.textContentType = .newPassword
        return model
    }()

    var canGoNext: Bool {
        if confrimText.count < 8 || text.count < 8 {
            return false
        }

        return confrimText == text && isTick
    }

    var buttonState: VPrimaryButtonState {
        if viewModel.isLoading {
            return .loading
        }
        return canGoNext ? .enabled : .disabled
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading) {
                Text("create_backup".localized)
                    .bold()
                    .foregroundColor(Color.LL.text)
                    .font(.LL.largeTitle)

                Text("password".localized)
                    .bold()
                    .foregroundColor(Color.LL.orange)
                    .font(.LL.largeTitle)

                Text("password_use_tips".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 30)

            Spacer()

            VStack(spacing: 30) {
                VTextField(model: model,
                           type: .secure,
                           highlight: highlight,
                           placeholder: "backup_password".localized,
                           footerTitle: "minimum_8_char".localized,
                           text: $text,
                           onChange: {
                               viewModel.trigger(.onPasswordChanged(text))
                           })

                VTextField(model: model,
                           type: .secure,
                           highlight: confrimHighlight,
                           placeholder: "confirm_password".localized,
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
                      title: "can_not_recover_pwd_tips".localized)
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)

            VPrimaryButton(model: ButtonStyle.primary,
                           state: buttonState,
                           action: {
                               viewModel.trigger(.secureBackup(confrimText))
                           },
                           title: "secure_backup".localized)
                .padding(.bottom)
        }
        .padding(.horizontal, 30)
        .navigationTitle("".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
    }
}

struct BackupPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        BackupPasswordView(viewModel: BackupPasswordViewModel(backupType: .googleDrive).toAnyViewModel())
            .previewDevice("iPhone 12 mini")
            .environment(\.locale, .init(identifier: "en"))
    }
}
