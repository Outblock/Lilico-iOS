//
//  ConfirmPinCodeView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI

extension ConfirmPinCodeView {
    struct ViewState {
        let lastPin: String
        var mismatch: Bool = false
    }

    enum Action {
        case match(String)
    }
}

struct ConfirmPinCodeView: View {
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
    var text: String = ""

    @State
    var focuse: Bool = false

    var wrongAttempt: Bool {
        if viewModel.mismatch {
            text = ""
            return true
        }
        return false
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Please Confirm")
                        .bold()
                        .foregroundColor(Color.LL.text)
                        .font(.LL.largeTitle)
                    HStack {
                        Text("your")
                            .bold()
                            .foregroundColor(Color.LL.text)

                        Text("PIN")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                    }
                    .font(.LL.largeTitle)

                    Text("There’s no Restore PIN button. Please make sure you can remember your PIN.")
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                SecureView(text: $text) { text, complete in
                    if complete {
                        viewModel.trigger(.match(text))
                        if viewModel.state.mismatch {
                            self.text = ""
                        }
                    }
                }
                .offset(x: viewModel.state.mismatch ? -10 : 0)
                .animation(.easeInOut(duration: 0.08).repeatCount(5), value: viewModel.state.mismatch)

                Spacer()
            }
            .onAppear {
//                delay(.milliseconds(500)) {
//                    self.focuse = true
//                }
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct ConfirmPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmPinCodeView(viewModel: ConfirmPinCodeViewModel(pin: "111111").toAnyViewModel())
//            .colorScheme(.dark)
    }
}

