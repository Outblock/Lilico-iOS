//
//  UsernameView.swift
//  Lilico
//
//  Created by Hao Fu on 26/12/21.
//

import SwiftUI
import SwiftUIX

extension UsernameView {
    struct ViewState {
        var status: LL.TextField.Status = .normal
    }

    enum Action {
        case next
        case onEditingChanged(String)
    }
}

struct UsernameView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    @State
    var text: String = ""

    var highlight: VTextFieldHighlight {
        switch viewModel.status {
        case .success:
            return .success
        case .error:
            return .error
        case .normal:
            return .none
        case .loading:
            return .loading
        }
    }

    var footerText: String {
        switch viewModel.status {
        case .success:
            return "nice_one".localized
        case let .error(message):
            return message
        case .normal:
            return " "
        case .loading:
            return "checking".localized
        }
    }

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
                    Text("pick_your".localized)
                        .font(.LL.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    Text("username".localized)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                    Text("username_desc".localized)
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VTextField(model: TextFieldStyle.primary,
                           type: .userName,
                           highlight: highlight,
                           placeholder: "username".localized,
                           footerTitle: footerText,
                           text: $text,
                           onChange: {
                               viewModel.trigger(.onEditingChanged(text))
                           },
                           onReturn: .returnAndCustom {
                               viewModel.trigger(.next)
                           }, onClear: .clearAndCustom {
                               viewModel.trigger(.onEditingChanged(text))
                           })
                           .padding(.bottom, 10)

                VPrimaryButton(model: ButtonStyle.primary,
                               state: highlight == .success ? .enabled : .disabled,
                               action: {
                    viewModel.trigger(.next)
                }, title: "next".localized)
                    .padding(.bottom)
            }
            .dismissKeyboardOnDrag()
            .padding(.horizontal, 28)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
    }
}
