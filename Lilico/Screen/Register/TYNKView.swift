//
//  TYNKView.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import SwiftUI
import SwiftUIX

extension TYNKView {
    struct ViewState {
        var isLoading = false
    }

    enum Action {
        case createWallet
    }
}

struct TYNKView: View {
    @Environment(\.presentationMode)
    var presentationMode: Binding<PresentationMode>

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    @State
    var stateList: [Bool] = [false, false, false]

    var btnBack: some View {
        Button {
//            self.presentationMode.wrappedValue.dismiss()

        } label: {
            HStack {
                Image(systemName: "arrow.backward")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.LL.rebackground)
            }
        }
    }

    var buttonState: VPrimaryButtonState {
        if viewModel.isLoading {
            return .loading
        }
        return stateList.contains(false) ? .disabled : .enabled
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Things you")
                        .font(.LL.largeTitle)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)
                    HStack {
                        Text("Need to")
                            .bold()
                            .foregroundColor(Color.LL.rebackground)

                        Text("Know")
                            .bold()
                            .foregroundColor(Color.LL.orange)
                    }
                    .font(.LL.largeTitle)

                    Text("In the next step, you will see a secret phrase (12 words). The secret phrase is the only key to recover your wallet.")
                        .font(.LL.body)
                        .foregroundColor(.LL.note)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VStack(spacing: 12) {
                    ConditionView(isOn: $stateList[0],
                                  text: "If I lose my secret phrases, I cannot access my account forever.")
                    ConditionView(isOn: $stateList[1],
                                  text: "If I expose my secret phrases anywhere, my funds can be stolen.")
                    ConditionView(isOn: $stateList[2],
                                  text: "It is my full responsibility to secure my secret phrases.")
                }
                .padding(.bottom, 40)

                VPrimaryButton(model: ButtonStyle.primary,
                               state: buttonState,
                               action: {
                                   viewModel.trigger(.createWallet)
                }, title: buttonState == .loading ? "Almost there" : "Next")
                    .padding(.bottom)
            }
            .padding(.horizontal, 28)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct TYNKView_Previews: PreviewProvider {
    static var previews: some View {
        TYNKView(viewModel: TYNKViewModel(username: "123").toAnyViewModel())
            .previewDevice("iPhone 13 mini")
    }
}

struct ConditionView: View {
    @Binding
    var isOn: Bool

    var text: String

    var model: VCheckBoxModel = {
        var model = VCheckBoxModel()
        model.layout.dimension = 20
        model.layout.cornerRadius = 6
        model.layout.contentMarginLeading = 15

        model.colors.textContent = .init(off: Color.LL.text,
                                         on: Color.LL.text,
                                         indeterminate: Color.LL.text,
                                         pressedOff: Color.LL.text,
                                         pressedOn: Color.LL.text,
                                         pressedIndeterminate: Color.LL.text,
                                         disabled: Color.LL.text)

        model.colors.fill = .init(off: .clear,
                                  on: Color.LL.orange,
                                  indeterminate: Color.LL.orange,
                                  pressedOff: Color.LL.orange.opacity(0.5),
                                  pressedOn: Color.LL.orange.opacity(0.5),
                                  pressedIndeterminate: Color.LL.orange,
                                  disabled: .gray)

        model.colors.icon = .init(off: .clear,
                                  on: Color.LL.background,
                                  indeterminate: Color.LL.background,
                                  pressedOff: Color.LL.background.opacity(0.5),
                                  pressedOn: Color.LL.background.opacity(0.5),
                                  pressedIndeterminate: Color.LL.background,
                                  disabled: Color.LL.background)
        return model
    }()

    var body: some View {
        Button {
            isOn.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack {
                VCheckBox(model: model,
                          isOn: $isOn)
                    .padding(.horizontal, 12)
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 30, alignment: .leading)
                    .allowsHitTesting(false)
                    .frame(width: 30, height: 30, alignment: .center)

                Text(text)
                    .padding(.horizontal, 13)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.LL.body)
                    .foregroundColor(.LL.text)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.8)
            }
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 1)
                    .foregroundColor(isOn ? Color.LL.orange : .separator)
            }
        }
    }
}
