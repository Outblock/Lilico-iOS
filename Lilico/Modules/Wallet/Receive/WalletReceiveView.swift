//
//  WalletReceiveView.swift
//  Lilico
//
//  Created by Selina on 6/7/2022.
//

import SwiftUI
import QRCode
import LinkPresentation

struct WalletReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletReceiveView()
        }
    }
}

struct WalletReceiveView: RouteableView {
    @StateObject var vm = WalletReceiveViewModel()
    
    var title: String {
        return ""
    }
    
    func backButtonAction() {
        Router.dismiss()
    }
    
    @State var isDismissing: Bool = false
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    @State var isShowing: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            //            addressView
            Spacer()
            
            if isShowing {
                VStack(alignment: .center, spacing: 15) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.LL.Neutrals.neutrals8)
                    
                    qrCodeContainerView
            
                    copyButton
                    
                    shareButton
                }
                .transition(.offset(CGSize(width: 0, height: UIScreen.screenHeight/2)))
            }
            
            Spacer()
            
                        
        }
        .animation(.alertViewSpring, value: isShowing)
        .offset(x: 0, y: self.dragOffset.height > 0 ?  self.dragOffset.height : 0)
        .gesture(DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation
                self.dragOffsetPredicted = value.predictedEndTranslation
            }
            .onEnded { value in
                if((self.dragOffset.height > 100) || (self.dragOffsetPredicted.height / (self.dragOffset.height)) > 2) {
                    withAnimation(.spring()) {
                        //                        self.dragOffset = self.dragOffsetPredicted
                        self.dragOffset = CGSize(width: 0, height: UIScreen.screenHeight/2)
                    }
                    
                    self.isDismissing = true
                    self.isShowing = false
                    
                    // Hacky way
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        Router.dismiss(animated: false)
                    }
                    
                    return
                } else {
                    withAnimation(.interactiveSpring()) {
                        self.dragOffset = .zero
                    }
                }
            }
        )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(
            Color(hex: "#333333")
                .opacity(isShowing ? (1.0 - ( Double(max(0,self.dragOffset.height)) / 1000)) : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.alertViewSpring, value: isShowing)
            
        )
        .edgesIgnoringSafeArea(.all)
        .applyRouteable(self)
        .onAppear{
            isShowing = true
            dragOffset = .zero
            dragOffsetPredicted = .zero
        }
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
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .padding(10)
                    .background(
                        Color.LL.Neutrals.background
//                        .thickMaterial
//                            .opacity(0.95)
//                            .blur(radius: 2)
                    )
                    .colorScheme(.light)
                    .cornerRadius(50)
            }
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(LocalUserDefaults.shared.flowNetwork == .mainnet ? Color.LL.Neutrals.background : Color.LL.flow, lineWidth: 5)
                    .colorScheme(.light)
            )
            .aspectRatio(1, contentMode: .fit)
            
        }
        .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.75)
        .aspectRatio(1, contentMode: .fill)
    }
    
    var copyButton: some View {
        
        Button {
            vm.copyAddressAction()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            VStack(spacing: 12) {
                
                HStack {
                    Text("Flow Address".localized)
                        .font(.LL.mindTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.LL.Neutrals.background)
                        .colorScheme(.light)
                    
                    if LocalUserDefaults.shared.flowNetwork == .testnet {
                        Text("testnet".localized)
                            .textCase(.uppercase)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .font(.inter(size: 12, weight: .semibold))
                            .foregroundColor(.LL.flow)
                            .background(
                                Capsule(style: .circular)
                                    .fill(Color.LL.flow.opacity(0.2))
                            )
                    }
                }
                
                Label {
                    Text(vm.address)
                        .font(.LL.largeTitle3)
                        .fontWeight(.semibold)
                        .foregroundColor(.LL.Neutrals.neutrals6)
                        .padding(.bottom, 20)
                } icon: {
                    Image("Copy")
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.vertical, 10)
    }
    
    var shareButton: some View {
        
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            
            let image = qrCodeContainerView.snapshot()
            
            let itemSource = ShareActivityItemSource(shareText: vm.address, shareImage: image)
            
            let activityController = UIActivityViewController(activityItems: [image, vm.address, itemSource], applicationActivities: nil)
            activityController.isModalInPresentation = true
            UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(activityController, animated: true, completion: nil)
            
        } label: {

            Label {
                Text("Share".localized)
                    .font(.LL.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundColor(.LL.Neutrals.neutrals6)
            .padding(12)
            .padding(.horizontal, 8)
            .background(.LL.Neutrals.neutrals1)
            .shadow(radius: 10)
            .cornerRadius(16)
            .colorScheme(.light)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

extension WalletReceiveView {
    var contentShape: QRCode.Shape {
        let shape = QRCode.Shape()
        shape.eye = QRCode.EyeShape.Squircle()
        shape.data = QRCode.DataShape.Circle(inset: 1 )
        return shape
    }
    
    var color: Color {
        LocalUserDefaults.shared.flowNetwork == .mainnet ?
        Color.LL.Neutrals.text :
        Color.LL.Neutrals.text
    }
    
    var qrCodeView: some View {
        let codeView = QRCodeUI(text: vm.address, errorCorrection: .high, contentShape: contentShape)!
        
        let v =
        ZStack {
            codeView
                .components(.eyeOuter)
                .fill(color)
                .colorScheme(.light)
            
            codeView
                .components(.eyePupil)
                .fill(
                    LocalUserDefaults.shared.flowNetwork == .mainnet ?
                    Color.LL.Primary.salmonPrimary:
                    Color.LL.text
                )
                .colorScheme(.light)
            
            codeView
                .components(.onPixels)
                .fill(color)
                .colorScheme(.light)
        }
        .padding(8)
        .background(
            Color.LL.Neutrals.background
        )
        .colorScheme(.light)
        .preferredColorScheme(.light)
        
        return v
    }
}
