//
//  EnterPasswordView.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI
import SwiftUIX

struct EnterRestorePasswordView: View {
    @EnvironmentObject var router: LoginCoordinator.Router
    @StateObject var vm: EnterRestorePasswordViewModel
    
    @State var text: String = ""
    @State var textStatus: LL.TextField.Status = .normal
    @State var state: VTextFieldState = .enabled
    
    var buttonState: VPrimaryButtonState {
        text.count >= 8 ? .enabled : .disabled
    }
    
    var model: VTextFieldModel = {
        var model = TextFieldStyle.primary
        model.misc.textContentType = .password
        return model
    }()
    
    init(driveItem: BackupManager.DriveItem) {
        _vm = StateObject(wrappedValue: EnterRestorePasswordViewModel(driveItem: driveItem))
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("enter".localized)
                        .foregroundColor(Color.LL.text)
                        .bold()
                    Text("password".localized)
                        .foregroundColor(Color.LL.orange)
                        .bold()
                }
                .font(.LL.largeTitle)
                
                Text("pwd_created_tips".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VTextField(model: model,
                       type: .secure,
                       state: $state,
                       placeholder: "enter_your_password".localized,
                       footerTitle: "minimum_8_char".localized,
                       text: $text) {}
                .frame(height: 120)
                .padding(.top, 80)
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: buttonState,
                           action: {
                state = .enabled
                vm.restoreAction(password: text)
            }, title: "restore_account".localized)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
        .navigationTitle("".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            router.pop()
        }
        .backgroundFill(Color.LL.background)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                state = .focused
            }
        }
    }
}

//struct EnterPasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnterRestorePasswordView()
//    }
//}
