//
//  InputMnemonicView.swift
//  Lilico
//
//  Created by Hao Fu on 8/1/22.
//

import SwiftUI
import SwiftUIX

extension InputMnemonicView {
    struct ViewState {
        var nextEnable: Bool = false
        var hasError: Bool = false
        var suggestions: [String] = []
        var text: String = ""
    }

    enum Action {
        case next
        case onEditingChanged(String)
    }
}

struct InputMnemonicView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @EnvironmentObject
    var router: LoginCoordinator.Router

    @StateObject
    var viewModel: InputMnemonicViewModel

    var btnBack: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }

    var nextBack: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.trigger(.next)
        } label: {
            HStack {
                Text("next".localized)
                    .foregroundColor(viewModel.state.nextEnable ? Color.LL.text : Color.LL.note)
            }
        }
    }

    @State
    var offset: CGFloat = 10

    var model: VTextFieldModel = {
        var model = TextFieldStyle.primary
        model.colors.clearButtonIcon = .clear
        model.layout.height = 150
        return model
    }()

    var body: some View {
        VStack {
            NavigationView {
                VStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("sign_in_with".localized)
                            .foregroundColor(Color.LL.text)
                            .bold()
                            .font(.LL.largeTitle)
//                            .minimumScaleFactor(0.5)

                        Text("recovery_phrase".localized)
                            .foregroundColor(Color.LL.orange)
                            .bold()
                            .font(.LL.largeTitle)
//                            .minimumScaleFactor(0.5)

                        Text("phrase_you_created_desc".localized)
                            .lineSpacing(5)
                            .font(.LL.body)
                            .foregroundColor(.LL.note)
                            .padding(.top, 1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom)
                    .padding(.horizontal, 28)
                    .minimumScaleFactor(0.9)

                    ZStack(alignment: .topLeading) {
                        if viewModel.state.text.isEmpty {
                            Text("enter_rp_placeholder".localized)
                                .font(.LL.body)
                                .foregroundColor(.LL.note)
                                .padding(.all, 10)
                                .padding(.top, 2)
                        }

                        TextEditor(text: $viewModel.state.text)
                            .introspectTextView { view in
                                view.becomeFirstResponder()
                                view.tintColor = Color.LL.orange.toUIColor()
                                view.backgroundColor = .clear
                            }
                            .keyboardType(.alphabet)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: viewModel.state.text, perform: { value in
                                viewModel.trigger(.onEditingChanged(value))
                            })
                            .font(.LL.body)
                            .frame(height: 120)
                            .padding(4)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 1)
                                    .foregroundColor(viewModel.state.hasError ? .LL.error : .LL.text)
                            }
                    }
                    .padding(.horizontal, 28)

                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.LL.footnote)
                        Text("words_not_found".localized)
                            .font(.LL.footnote)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(viewModel.state.hasError ? .LL.error : .LL.text)
                    .padding(.horizontal, 28)
                    .opacity(viewModel.state.hasError ? 1 : 0)
                    .animation(.linear, value: viewModel.state.hasError)

                    VPrimaryButton(model: ButtonStyle.primary,
                                   state: viewModel.state.nextEnable ? .enabled : .disabled,
                                   action: {
                                       viewModel.trigger(.next)
                                   }, title: "next".localized)
                        .padding(.horizontal, 28)

                    Spacer()

                    ScrollView(.horizontal, showsIndicators: false, content: {
                        LazyHStack(alignment: .center, spacing: 10, content: {
                            Text("  ")
                            ForEach(viewModel.state.suggestions, id: \.self) { word in

                                Button {
//                                    viewModel.trigger(.tapSuggestion(word))
                                    let last = viewModel.state.text.split(separator: " ").last ?? ""
                                    viewModel.state.text.removeLast(last.count)
                                    viewModel.state.text.append(word)
                                    viewModel.state.text.append(" ")

                                } label: {
                                    Text(word)
                                        .foregroundColor(.LL.text)
                                        .font(.LL.subheadline)
                                        //                                    .semibold()
                                        .padding(5)
                                        .padding(.horizontal, 5)
                                        .background(.LL.outline)
                                        .cornerRadius(10)
                                }
                            }
                            Text("  ")
                        })
                    })
//                        .keyboardSensible($offset)
                    .frame(height: 30, alignment: .leading)
                    .padding(.bottom)
                }
//                .ignoresSafeArea(.keyboard)
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: btnBack)
//                .navigationBarItems(trailing: nextBack)
                .background(Color.LL.background, ignoresSafeAreaEdges: .all)
            }
        }
    }
}

struct InputMnemonicView_Previews: PreviewProvider {
    static var previews: some View {
        InputMnemonicView(viewModel: InputMnemonicViewModel())
            .previewDevice("iPhone 13 mini")
    }
}
