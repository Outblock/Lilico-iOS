//
//  ConfirmPinCodeView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI

extension ConfirmPinCodeView {
    enum ViewState {
        //        var isLoading = false
//        var dataSource: [BackupModel]
        case initScreen
    }

    enum Action {}
}

struct ConfirmPinCodeView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

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
    var text: String

    @State var wrongAttempt: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Please Confirm")
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                        .font(.largeTitle)
                    HStack {
                        Text("your")
                            .bold()
                            .foregroundColor(Color.LL.rebackground)
                            .font(.largeTitle)

                        Text("Pin")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                            .font(.largeTitle)
                    }
                    .font(.largeTitle)

                    Text("There’s no Restore PIN button. Please make sure you can remember your PIN.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                PinStackView(maxDigits: 6,
                             emptyColor: .gray.opacity(0.2),
                             highlightColor: Color.LL.orange,
                             needClear: wrongAttempt) { _, complete in
                    if complete {
                        self.wrongAttempt = true
                    }
                }
                .offset(x: wrongAttempt ? -10 : 0)
                .animation(.easeInOut(duration: 0.08).repeatCount(5), value: wrongAttempt)

                Spacer()
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
        ConfirmPinCodeView(text: "")
//            .colorScheme(.dark)
    }
}
