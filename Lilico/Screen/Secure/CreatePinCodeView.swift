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
    struct ViewState {
    }

    enum Action {
        case input(String)
    }
}

struct CreatePinCodeView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @EnvironmentObject
    var rounter: SecureCoordinator.Router
    
    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

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
    var text: String = ""
    
    @State
    var focuse: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                Spacer()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Create a")
                            .bold()
                            .foregroundColor(Color.LL.text)

                        Text("PIN")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                    }
                    .font(.LL.largeTitle)

                    Text("So no one else but you can unlock your wallet.")
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 30)

                PinStackView(maxDigits: 6,
                             emptyColor: .gray.opacity(0.2),
                             highlightColor: Color.LL.orange,
                             pin: $text) { text, isComplete in
                    viewModel.trigger(.input(text))
                }

                Spacer()
            }
            .onAppear{
                
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

struct CreatePinCodeView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePinCodeView(viewModel: CreatePinCodeViewModel().toAnyViewModel())
//            .colorScheme(.dark)
    }
}
