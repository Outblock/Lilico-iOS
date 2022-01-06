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
    @EnvironmentObject
    var router: RegisterCoordinator.Router

    @StateObject
    var viewModel: AnyViewModel<ViewState, Action>

    @State
    var stateList: [Bool] = [false, false, false]

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
                        .font(.largeTitle)
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
                    .font(.largeTitle)

                    Text("In the next step, you will see a secret phrase (12 words). The secret phrase is the only key to recover your wallet.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()

                VStack {
                    ConditionView(isOn: $stateList[0],
                                  text: "If I lose my secret phrases, I cannot access my account forever.")
                    ConditionView(isOn: $stateList[1],
                                  text: "If I lose my secret phrases, I cannot access my account forever.")
                    ConditionView(isOn: $stateList[2],
                                  text: "If I lose my secret phrases, I cannot access my account forever.")
                }.padding(.bottom)

                VPrimaryButton(model: ButtonStyle.primary,
                               state: buttonState,

                               action: {
                                   viewModel.trigger(.createWallet)
                               }, title: "Next")
                    .padding(.bottom)
            }
            .padding(.horizontal, 30)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
            .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        }
    }
}

struct TYNKView_Previews: PreviewProvider {
    static var previews: some View {
        TYNKView(viewModel: TYNKViewModel(username: "123").toAnyViewModel())
            .previewDevice("iPhone 13 Pro")
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
        VCheckBox(model: model,
                  isOn: $isOn,
                  title: text)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 5)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 1)
                    .foregroundColor(isOn ? Color.LL.orange : .separator)
            }
            .padding(.bottom)
    }
}
