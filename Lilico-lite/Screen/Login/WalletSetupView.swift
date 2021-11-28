//
//  WalletSetupView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 26/11/21.
//

import SwiftUI
import SwiftUIX

struct WalletSetupView: View {
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Text("Get started")
                        .font(.title)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        
                    } label: {
                      Text("Create Wallet")
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                        .foregroundColor(Color.LL.rebackground)
                        .background(
                            Color(hex: "#2F2E39"),
                            in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                        )
                        
                    
                    Divider()
//                        .foregroundColor(Color.LL.primary)
                        .background(Color.LL.primary)
                        .padding(.horizontal, 20)
                    
                    HStack(alignment: .center, spacing: 20) {
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "applelogo")
                                .font(.title.bold())
                                .foregroundColor(Color.LL.rebackground)
                                .padding(25)
                                .background(
                                    Color.LL.rebackground.opacity(0.1),
                                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
                                )
                        }
                        
//                        Button {
//                            
//                        } label: {
//                            Text(AwesomeIcon.google.rawValue)
//                                .font(.awesome(style: .brand, size: 20))
////                            Image(systemName: "applelogo")
//                                .font(.title.bold())
//                                .foregroundColor(Color.LL.rebackground)
//                                .padding(25)
//                                .background(
//                                    Color.LL.rebackground.opacity(0.1),
//                                    in: RoundedRectangle(cornerSize: CGSize(width: 20, height: 20))
//                                )
//                        }
                    }
                }.padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.LL.rebackground.opacity(0.1))
                    .mask {
                        RoundedRectangle(cornerRadius: 30)
//                            .strokeBorder(Color.LL.primary, lineWidth: 2)
//                            .blendMode(.overlay)
                    }
//                    .modifier(OutlineModifier(cornerRadius: 30))
                    
//                    .cornerRadius(15)
                    .padding(30)
//                    .cornerRadius([.topRight, .topLeft], 30)
            }
        }.background(Color.LL.background.edgesIgnoringSafeArea(.all))
    }
    
    
}

struct WalletSetupView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSetupView().colorScheme(.dark)
        WalletSetupView()
    }
}


struct OutlineModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(
                    .linearGradient(
                        colors: [
                            .white.opacity(colorScheme == .dark ? 0.1 : 0.3),
                            .black.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing)
                )
        )
    }
}
