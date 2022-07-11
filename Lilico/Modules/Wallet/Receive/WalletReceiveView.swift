//
//  WalletReceiveView.swift
//  Lilico
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI
import QRCode

//struct WalletReceiveView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            WalletReceiveView()
//        }
//    }
//}

struct WalletReceiveView: View {
    @EnvironmentObject private var router: WalletReceiveCoordinator.Router
    @StateObject var vm = WalletReceiveViewModel()
    
    var body: some View {
        VStack(spacing: -30) {
            addressView
            qrCodeContainerView
            
            Spacer()
            
            copyButton
        }
        .navigationTitle("receive".localized)
        .navigationBarTitleDisplayMode(.large)
        .interactiveDismissDisabled()
        .addBackBtn {
            router.dismissCoordinator()
        }
        .buttonStyle(.plain)
        .backgroundFill(Color.LL.deepBg)
    }
    
    var addressView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("wallet_address".localized)
                    .foregroundColor(.white)
                    .font(.inter(size: 14, weight: .semibold))
                Text("(\(vm.address))")
                    .foregroundColor(.white)
                    .font(.inter(size: 14, weight: .medium))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.LL.Primary.salmonPrimary.cornerRadius(16))
        .padding(.horizontal, 18)
        .zIndex(1)
    }
    
    var qrCodeContainerView: some View {
        VStack(spacing: 0) {
            ZStack {
                qrCodeView
            }
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(16)
            
            Text("qr_code_str".localized)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 16, weight: .semibold))
                .padding(.top, 24)
            
            Text("qr_code_desc".localized)
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 12, weight: .medium))
                .padding(.top, 16)
        }
        .padding(.top, 79)
        .padding(.bottom, 43)
        .padding(.horizontal, 27)
        .background(.LL.bgForIcon)
        .cornerRadius(16)
        .padding(.horizontal, 33)
    }
    
    var copyButton: some View {
        Button {
            vm.copyAddressAction()
        } label: {
            Text("copy".localized)
                .foregroundColor(.LL.Button.text)
                .font(.inter(size: 14, weight: .semibold))
                .frame(width: 64, height: 32)
                .background {
                    Color.LL.Button.color.cornerRadius(16)
                }
                .padding(.bottom, 20)
        }

    }
}

extension WalletReceiveView {
    var contentShape: QRCode.Shape {
        let shape = QRCode.Shape()
        shape.eye = QRCode.EyeShape.Squircle()
        shape.data = QRCode.DataShape.RoundedPath()
        return shape
    }
    
    var qrCodeView: some View {
        let codeView = QRCodeUI(text: vm.address, errorCorrection: .high, contentShape: contentShape)!
        
        let v =
        ZStack {
            codeView
                .components(.eyeOuter)
                .fill(Color.LL.Neutrals.text)
            
            codeView
                .components(.eyePupil)
                .fill(Color.LL.Primary.salmonPrimary)
            
            codeView
                .components(.onPixels)
                .fill(Color.LL.Neutrals.text)
        }
        .background(Color.LL.Neutrals.background)
        
        return v
    }
}
