//
//  WalletSendAmountView.swift
//  Lilico
//
//  Created by Selina on 12/7/2022.
//

import SwiftUI
import Kingfisher

struct WalletSendAmountView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSendAmountView()
    }
}

extension WalletSendAmountView {
    enum ExchangeType {
        case token
        case dollar
    }
    
    enum ErrorType {
        case none
        case insufficientBalance
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            }
        }
    }
}

struct WalletSendAmountView: View {
    @EnvironmentObject private var router: WalletSendCoordinator.Router
    @State var contact: Contact = Contact(address: "0x93da24f027c675c5", avatar: "", contactName: "ContactName", contactType: .domain, domain: Contact.Domain(domainType: .flowns, value: ""), id: UUID().hashValue, username: nil)
    @State var inputText: String = ""
    @State var aboutEqualToName: String = "Flow"
    @State var aboutEqualToNum: Double = 0.1
    @State var exchangeType: ExchangeType = .token
    @State var errorType: ErrorType = .none
    
    var body: some View {
        VStack(spacing: 24) {
            targetView
            transferInputContainerView
            amountBalanceView
            
            Spacer()
        }
        .navigationTitle("send_to".localized)
        .navigationBarTitleDisplayMode(.large)
        .interactiveDismissDisabled()
        .addBackBtn {
            router.pop()
        }
        .buttonStyle(.plain)
        .backgroundFill(Color.LL.deepBg)
    }
    
    var targetView: some View {
        HStack(spacing: 15) {
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

            // text
            VStack(alignment: .leading, spacing: 3) {
                Text(contact.contactName ?? "no name")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .bold))

                Text(contact.address ?? "no address")
                    .foregroundColor(.LL.Neutrals.note)
                    .font(.inter(size: 14, weight: .regular))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                
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
                        .visibility(exchangeType == .dollar ? .visible : .gone)
                    
                    // switch btn
                    Button {
                        
                    } label: {
                        HStack(spacing: 8) {
                            Image("icon-us-dollar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32)
                            
                            Image("icon-arrow-bottom")
                                .foregroundColor(.LL.Neutrals.neutrals3)
                        }
                    }
                    .visibility(exchangeType == .token ? .visible : .gone)

                    // input view
                    TextField("", text: $inputText)
                        .modifier(PlaceholderStyle(showPlaceHolder: inputText.isEmpty,
                                                   placeholder: "enter_amount".localized,
                                                   font: .inter(size: 14, weight: .medium),
                                                   color: Color.LL.Neutrals.note))
                        .autocorrectionDisabled()
                        .onChange(of: inputText) { text in
                            withAnimation {
                                if text.isEmpty {
                                    errorType = .none
                                } else {
                                    errorType = .insufficientBalance
                                }
                            }
                        }
                    
                    // max btn
                    Button {
                        
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
                    
                    Text(exchangeType == .token ? "$" : "\(aboutEqualToName)")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .medium))
                    
                    Text("\(aboutEqualToNum.currencyString)")
                        .foregroundColor(.LL.Neutrals.note)
                        .font(.inter(size: 16, weight: .medium))
                    
                    Button {
                        toggleExchangeTypeAction()
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
    
    var errorTipsView: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 9) {
                Image(systemName: .error)
                    .foregroundColor(Color(hex: "#C44536"))
                
                Text(errorType.desc)
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
        .visibility(errorType == .none ? .gone : .visible)
        .transition(.move(edge: .top))
    }
    
    var amountBalanceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("amount_balance".localized)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 14, weight: .medium))
                .padding(.bottom, 9)
            
            HStack {
                KFImage.url(nil)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .background(.LL.Neutrals.note)
                    .clipShape(Circle())
                
                Text("999 Flow")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .medium))
                
                Text("≈ $ 123.00")
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
}

extension WalletSendAmountView {
    func toggleExchangeTypeAction() {
        if exchangeType == .token {
            exchangeType = .dollar
        } else {
            exchangeType = .token
        }
    }
}
