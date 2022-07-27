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

struct ConfirmPinCodeView: RouteableView {
    @StateObject var viewModel: ConfirmPinCodeViewModel
    
    init(lastPin: String) {
        _viewModel = StateObject(wrappedValue: ConfirmPinCodeViewModel(pin: lastPin))
    }
    
    var title: String {
        return ""
    }

    @State var text: String = ""
    @State var focuse: Bool = false

    var wrongAttempt: Bool {
        if viewModel.state.mismatch {
            text = ""
            return true
        }
        return false
    }

    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            VStack(alignment: .leading) {
                Text("please_confirm".localized)
                    .bold()
                    .foregroundColor(Color.LL.text)
                    .font(.LL.largeTitle)
                HStack {
                    Text("your".localized)
                        .bold()
                        .foregroundColor(Color.LL.text)

                    Text("pin".localized)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                }
                .font(.LL.largeTitle)

                Text("no_restore_desc".localized)
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
        .padding(.horizontal, 28)
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        .applyRouteable(self)
    }
}

struct ConfirmPinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmPinCodeView(lastPin: "111111")
    }
}
