//
//  WalletSendAmountView.swift
//  Lilico
//
//  Created by Selina on 12/7/2022.
//

import SwiftUI
import Kingfisher
import Combine

//struct WalletSendAmountView_Previews: PreviewProvider {
//    static var previews: some View {
////        WalletSendAmountView()
////        WalletSendAmountView.SendConfirmProgressView()
//    }
//}

struct WalletSendAmountView: View {
    @EnvironmentObject private var router: WalletSendCoordinator.Router
    @StateObject private var vm: WalletSendAmountViewModel
    
    init(target: Contact) {
        let symbol = LocalUserDefaults.shared.recentToken ?? "flow"
        guard let token = WalletManager.shared.getToken(bySymbol: symbol) else {
            assert(false, "token should not be nil")
        }
        
        _vm = StateObject(wrappedValue: WalletSendAmountViewModel(target: target, token: token))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                targetView
                transferInputContainerView
                amountBalanceView
                
                Spacer()
                
                nextButton
            }
        }
        .hideKeyboardWhenTappedAround()
        .navigationTitle("send_to".localized)
        .navigationBarTitleDisplayMode(.large)
        .interactiveDismissDisabled()
        .addBackBtn {
            router.pop()
        }
        .buttonStyle(.plain)
        .backgroundFill(Color.LL.deepBg)
        .customBottomSheet(isPresented: $vm.showConfirmView, title: "confirmation".localized, background: { Color.LL.Neutrals.background }) {
            SendConfirmView()
        }
        .environmentObject(vm)
    }
    
    var targetView: some View {
        HStack(spacing: 15) {
            // avatar
            ZStack {
                if let avatar = vm.targetContact.avatar?.convertedAvatarString(), avatar.isEmpty == false {
                    KFImage.url(URL(string: avatar))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                } else if vm.targetContact.needShowLocalAvatar {
                    Image(vm.targetContact.localAvatar ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                } else {
                    if let contactType = vm.targetContact.contactType, let contactName = vm.targetContact.contactName, contactType == .external, contactName.isAddress {
                        Text("0x")
                            .foregroundColor(.LL.Primary.salmonPrimary)
                            .font(.inter(size: 24, weight: .semibold))
                    } else {
                        Text(String((vm.targetContact.contactName?.first ?? "A").uppercased()))
                            .foregroundColor(.LL.Primary.salmonPrimary)
                            .font(.inter(size: 24, weight: .semibold))
                    }
                }
            }
            .frame(width: 44, height: 44)
            .background(.LL.Primary.salmon5)
            .clipShape(Circle())

            // text
            VStack(alignment: .leading, spacing: 3) {
                Text(vm.targetContact.contactName ?? "no name")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .bold))

                Text(vm.targetContact.address ?? "no address")
                    .foregroundColor(.LL.Neutrals.note)
                    .font(.inter(size: 14, weight: .regular))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                router.pop()
            } label: {
                Image(systemName: .delete)
                    .foregroundColor(.LL.Neutrals.note)
            }

        }
        .padding(.horizontal, 16)
        .frame(height: 73)
        .background(.LL.bgForIcon)
        .cornerRadius(16)
        .padding(.horizontal, 18)
    }
    
    var transferInputContainerView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("transfer_amount".localized)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 14, weight: .medium))
                .padding(.bottom, 9)
            
            VStack(spacing: 34) {
                HStack(spacing: 8) {
                    // dollar type string
                    Text("$")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .bold))
                        .visibility(vm.exchangeType == .dollar ? .visible : .gone)
                    
                    switchMenuButton
                        .visibility(vm.exchangeType == .token ? .visible : .gone)

                    // input view
                    TextField("", text: $vm.inputText)
                        .modifier(PlaceholderStyle(showPlaceHolder: vm.inputText.isEmpty,
                                                   placeholder: "enter_amount".localized,
                                                   font: .inter(size: 14, weight: .medium),
                                                   color: Color.LL.Neutrals.note))
                        .font(.inter(size: 20, weight: .medium))
                        .autocorrectionDisabled()
                        .onChange(of: vm.inputText) { text in
                            withAnimation {
                                vm.inputTextDidChangeAction(text: text)
                            }
                        }
                    
                    // max btn
                    Button {
                        vm.maxAction()
                    } label: {
                        Text("max".localized)
                            .foregroundColor(.LL.Button.color)
                            .font(.inter(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .frame(height: 26)
                            .background(.LL.Neutrals.neutrals10)
                            .cornerRadius(16)
                    }
                }
                
                // rate container
                HStack {
                    Text("≈")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .medium))
                    
                    Text("$")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .medium))
                        .visibility(vm.exchangeType == .token ? .visible : .gone)
                    
                    KFImage.url(vm.token.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .background(Color.LL.Neutrals.note)
                        .clipShape(Circle())
                        .visibility(vm.exchangeType == .dollar ? .visible : .gone)
                    
                    Text(vm.exchangeType == .token ? vm.inputDollarNum.currencyString : vm.inputTokenNum.currencyString)
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .medium))
                        .lineLimit(1)
                    
                    Button {
                        vm.toggleExchangeTypeAction()
                    } label: {
                        Image("icon-exchange").renderingMode(.template).foregroundColor(.LL.Neutrals.text)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 121)
            .background(.LL.bgForIcon)
            .cornerRadius(16)
            .zIndex(1)
            
            errorTipsView
        }
        .padding(.horizontal, 18)
    }
    
    var switchMenuButton: some View {
        Menu {
            ForEach(WalletManager.shared.activatedCoins) { token in
                Button {
                    vm.changeTokenModelAction(token: token)
                } label: {
                    KFImage.url(token.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                    Text(token.name)
                }
            }
        } label: {
            HStack(spacing: 8) {
                KFImage.url(vm.token.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .background(Color.LL.Neutrals.note)
                    .clipShape(Circle())
                
                Image("icon-arrow-bottom")
                    .foregroundColor(.LL.Neutrals.neutrals3)
            }
        }
    }
    
    var errorTipsView: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 9) {
                Image(systemName: .error)
                    .foregroundColor(Color(hex: "#C44536"))
                
                Text(vm.errorType.desc)
                    .foregroundColor(.LL.Neutrals.note)
                    .font(.inter(size: 12, weight: .regular))
            }
            .padding(.bottom, 12)
            .padding(.horizontal, 13)
        }
        .frame(height: 61)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#C44536").opacity(0.08))
        .cornerRadius(16)
        .padding(.top, -23)
        .padding(.horizontal, 5)
        .visibility(vm.errorType == .none ? .gone : .visible)
        .transition(.move(edge: .top))
    }
    
    var amountBalanceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("amount_balance".localized)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 14, weight: .medium))
                .padding(.bottom, 9)
            
            HStack {
                KFImage.url(vm.token.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .background(.LL.Neutrals.note)
                    .clipShape(Circle())
                
                Text("\(vm.amountBalance.currencyString) \(vm.token.symbol?.uppercased() ?? "?")")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .medium))
                
                Text("≈ $ \(vm.amountBalanceAsDollar.currencyString)")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
    
    var nextButton: some View {
        Button {
            vm.nextAction()
        } label: {
            ZStack {
                Text("next".localized)
                    .foregroundColor(Color.LL.Button.text)
                    .font(.inter(size: 14, weight: .bold))
            }
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background(Color.LL.Button.color)
            .cornerRadius(16)
            .padding(.horizontal, 18)
        }
        .disabled(!vm.isReadyForSend)
    }
}

extension WalletSendAmountView {
    struct SendConfirmView: View {
        @EnvironmentObject var vm: WalletSendAmountViewModel

        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    fromToView
                    WalletSendAmountView.SendConfirmProgressView()
                        .padding(.bottom, 37)
                }
                
                amountDetailView
                    .padding(.top, 37)
                
                sendButton
                    .padding(.top, 27)
                    .padding(.bottom, 20 + UIView.bottomSafeAreaHeight)
            }
            .padding(.horizontal, 28)
        }

        var fromToView: some View {
            HStack(spacing: 16) {
                contactView(contact: UserManager.shared.userInfo!.toContactWithCurrentUserAddress())
                Spacer()
                contactView(contact: vm.targetContact)
            }
        }

        func contactView(contact: Contact) -> some View {
            VStack(spacing: 5) {
                // avatar
                ZStack {
                    if let avatar = contact.avatar?.convertedAvatarString(), avatar.isEmpty == false {
                        KFImage.url(URL(string: avatar))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                    } else if contact.needShowLocalAvatar {
                        Image(contact.localAvatar ?? "")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                    } else {
                        Text(String((contact.contactName?.first ?? "A").uppercased()))
                            .foregroundColor(.LL.Primary.salmonPrimary)
                            .font(.inter(size: 24, weight: .semibold))
                    }
                }
                .frame(width: 44, height: 44)
                .background(.LL.Primary.salmon5)
                .clipShape(Circle())

                // contact name
                Text(contact.contactName ?? "name")
                    .foregroundColor(.LL.Neutrals.neutrals1)
                    .font(.inter(size: 14, weight: .semibold))
                    .lineLimit(1)

                // address
                Text(contact.address ?? "0x")
                    .foregroundColor(.LL.Neutrals.note)
                    .font(.inter(size: 12, weight: .regular))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        
        var amountDetailView: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("amount_confirmation".localized)
                    .foregroundColor(.LL.Neutrals.note)
                    .font(.inter(size: 14, weight: .medium))
                
                HStack(spacing: 0) {
                    KFImage.url(vm.token.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .background(Color.LL.Neutrals.note)
                        .clipShape(Circle())
                    
                    Text(vm.token.name)
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 18, weight: .medium))
                        .padding(.leading, 8)
                    
                    Spacer()
                    
                    Text("\(vm.inputTokenNum) \(vm.token.name.uppercased())")
                        .foregroundColor(.LL.Neutrals.text)
                        .font(.inter(size: 20, weight: .semibold))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .frame(height: 32)
                .padding(.top, 25)
                
                HStack {
                    Spacer()
                    
                    Text("USD $ \(vm.inputDollarNum.currencyString)")
                        .foregroundColor(.LL.Neutrals.neutrals8)
                        .font(.inter(size: 14, weight: .medium))
                }
                .padding(.top, 14)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(Color.LL.bgForIcon)
            .cornerRadius(16)
        }
        
        var sendButton: some View {
            Button {
                vm.sendAction()
            } label: {
                ZStack {
                    Text("send".localized)
                        .foregroundColor(Color.LL.Button.text)
                        .font(.inter(size: 14, weight: .bold))
                }
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Button.color)
                .cornerRadius(16)
                .padding(.horizontal, 18)
            }
        }
    }
    
    struct SendConfirmProgressView: View {
        private let totalNum: Int = 7
        @State private var step: Int = 0
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            HStack(spacing: 12) {
                ForEach(0..<totalNum, id: \.self) { index in
                    if step == index {
                        Image("icon-right-arrow-1")
                            .renderingMode(.template)
                            .foregroundColor(.LL.Primary.salmonPrimary)
                    } else {
                        switch index {
                        case 0:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon5)
                        case 1:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon4)
                        case 2:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon3)
                        default:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmonPrimary)
                        }
                    }
                }
            }
            .onReceive(timer) { _ in
                DispatchQueue.main.async {
                    if step < totalNum - 1 {
                        step += 1
                    } else {
                        step = 0
                    }
                }
            }
        }
    }
}
