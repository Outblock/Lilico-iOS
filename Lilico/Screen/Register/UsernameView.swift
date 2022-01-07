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
            return "Nice one"
        case let .error(message):
            return message
        case .normal:
            return " "
        case .loading:
            return "Checking"
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
                    Text("Pick Your")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    Text("Username")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                    Text("Other Lilico users can find you and send you payments via your unique username.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VTextField(model: TextFieldStyle.primary,
                           type: .userName,
                           highlight: highlight,
                           placeholder: "Username",
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
                               }, title: "Next")
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
