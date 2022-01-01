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
    
    var btnBack : some View {
        Button{
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
    
    let textModel: VTextFieldModel = {
        var model: VTextFieldModel = .init()

        model.colors.background = .clear
        model.colors.border = .init(enabled: .gray,
                                    focused: .black,
                                    success: .green,
                                    error: .red,
                                    disabled: .clear)
        model.layout.cornerRadius = 16
        model.layout.height = 60
        model.layout.headerFooterSpacing = 8
        return model
    }()
    
    let buttonModel: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()
        
        model.colors.textContent = .init(enabled: .white,
                                         pressed: .white,
                                         loading: .white,
                                         disabled: .white)
        
        model.colors.background = .init(enabled: .black,
                                        pressed: .black.opacity(0.8),
                                        loading: .black,
                                        disabled: .gray)
        
        model.layout.cornerRadius = 16
        return model
    }()
    
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
                
                VTextField(model: textModel,
                           type: .secure,
//                           highlight: .error,
                           placeholder: "Enter your password",
                           footerTitle: "Enter 8 characters, with at least 1 number",
                           text: $text) {
                    
                }
                .padding(.top, 50)
                
                Spacer()
                
                VPrimaryButton(model: buttonModel,
                               state: buttonState,
                               action: {
                    
                }, title: "Continue")
                
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
