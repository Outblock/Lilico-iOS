//
//  NFTTransferView.swift
//  Lilico
//
//  Created by Selina on 25/8/2022.
//

import SwiftUI
import Kingfisher
import Flow

class NFTTransferViewModel: ObservableObject {
    @Published var nft: NFTModel
    @Published var targetContact: Contact
    private var isRequesting: Bool = false
    
    init(nft: NFTModel, targetContact: Contact) {
        self.nft = nft
        self.targetContact = targetContact
    }
    
    func sendAction() {
        if SecurityManager.shared.securityType == .none {
            sendLogic()
            return
        }
        
        Task {
            let result = await SecurityManager.shared.inAppVerify()
            if result {
                sendLogic()
            }
        }
    }
    
    func sendLogic() {
        if isRequesting {
            return
        }
        
        guard let toAddress = targetContact.address else {
            return
        }
        
        isRequesting = true
        
        let successBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                Router.dismiss()
                HUD.success(title: "send_nft_success".localized)
            }
        }
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "send_nft_failed".localized)
            }
        }
        
        Task {
            do {
                let tid = try await FlowNetwork.transferNFT(to: Flow.Address(hex: toAddress), nft: nft)
                let result = try await tid.onceSealed()
                
                if result.isFailed {
                    debugPrint("NFTTransferViewModel -> sendAction result failed errorMessage: \(result.errorMessage)")
                    failedBlock()
                    return
                }
                
                if result.isComplete {
                    successBlock()
                    return
                }
            } catch {
                debugPrint("NFTTransferViewModel -> sendAction error: \(error)")
                failedBlock()
            }
        }
    }
}

struct NFTTransferView: View {
    @StateObject var vm: NFTTransferViewModel
    
    init(nft: NFTModel, target: Contact) {
        _vm = StateObject(wrappedValue: NFTTransferViewModel(nft: nft, targetContact: target))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: "send_nft".localized)
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    fromToView
                    NFTTransferView.SendConfirmProgressView()
                        .padding(.bottom, 37)
                }
                
                detailView
                    .padding(.top, 37)
                
                Spacer()
                
                sendButton
            }
            .padding(.horizontal, 28)
        }
        .backgroundFill(Color.LL.Neutrals.background)
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
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
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
    
    var detailView: some View {
        HStack(alignment: .center, spacing: 13) {
            KFImage.url(vm.nft.image)
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(vm.nft.title)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .bold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    KFImage.url(vm.nft.collection?.logoURL)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .cornerRadius(10)
                    
                    Text(vm.nft.collection?.name ?? "")
                        .foregroundColor(.LL.Neutrals.neutrals4)
                        .font(.inter(size: 14, weight: .regular))
                    
                    Image("flow")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
