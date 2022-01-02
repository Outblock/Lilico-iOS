//
//  UsernameView.swift
//  Lilico
//
//  Created by Hao Fu on 26/12/21.
//

import SwiftUI
import SwiftUIX

struct UsernameView: View {
    @EnvironmentObject
    var router: RegisterCoordinator.Router

    @StateObject
    var viewModel: AnyViewModel<UsernameViewState, UsernameViewAction>

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
            router.pop()
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

//                LL.TextField(placeHolder: "Username",
//                             text: $text,
//                             status: viewModel.status,
//                             onEditingChanged: { isEditing in
//                                 if isEditing {
//                                     viewModel.trigger(.onEditingChanged(text))
//                                 }
//                             })
//                             .padding(.bottom)

                VTextField(model: TextFieldStyle.primary,
                           type: .userName,
                           highlight: highlight,
                           placeholder: "Username",
                           footerTitle: footerText,
                           text: $text,
                           onChange: {
                               viewModel.trigger(.onEditingChanged(text))
                           },
                           onClear: .clearAndCustom {
                               viewModel.trigger(.onEditingChanged(text))
                           })
//                    .padding(.bottom)

                VPrimaryButton(model: ButtonStyle.primary,
                               state: highlight == .success ? .enabled : .disabled,
                               action: {}, title: "Next")
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
//                .padding(.bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
        }
    }
}

struct UsernameView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameView(viewModel: UsernameViewModel().toAnyViewModel())
    }
}
