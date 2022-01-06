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
    }
}

struct BackupPasswordView: View {
    @EnvironmentObject
    var router: BackupCorrdinator.Router

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

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

    @State
    var isTick: Bool = false

    var footerText: String = "1233"

    @State
    var highlight: VTextFieldHighlight = .none

    @State
    var text: String = ""

    var body: some View {
        NavigationView {
            VStack {
//                ScrollView {
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
                               onChange: {},
                               onReturn: .returnAndCustom {}, onClear: .clearAndCustom {})

                    VTextField(model: TextFieldStyle.primary,
                               type: .secure,
                               highlight: highlight,
                               placeholder: "Confirm Password",
                               footerTitle: "",
                               text: $text,
                               onChange: {},
                               onReturn: .returnAndCustom {}, onClear: .clearAndCustom {})
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
                               }, title: "Next")
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            //            .toolbar {
            //                ToolbarItem(placement: .principal) {
            //                    HStack {
            //                        Image(systemName: "sun.min.fill")
            //                        Text("Title").font(.headline)
            //                    }
            //                }
            //            }
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
