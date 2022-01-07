//
//  CreatePinCode.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Combine
import SwiftUI
import SwiftUIX

extension CreatePinCodeView {
    enum ViewState {
        //        var isLoading = false
//        var dataSource: [BackupModel]
        case initScreen
    }

    enum Action {}
}

struct CreatePinCodeView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

//    @StateObject
//    var viewModel: AnyViewModel<ViewState, Action>

//    @FocusState
//    var focusState: Bool

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

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Create a")
                            .bold()
                            .foregroundColor(Color.LL.rebackground)

                        Text("Pin")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                    }
                    .font(.largeTitle)

                    Text("So no one else but you can unlock your wallet.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                PinStackView(maxDigits: 6,
                             emptyColor: .gray.opacity(0.2),
                             highlightColor: Color.LL.orange) { _, _ in
                }

                Spacer()
            }
//            .onAppear{
//                focusState = true
//            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct CreatePinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePinCodeView(text: "")
//            .colorScheme(.dark)
    }
}
