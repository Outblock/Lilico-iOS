//
//  WalletView.swift
//  Lilico-lite
//
//  Created by Hao Fu on 30/11/21.
//

import SwiftUI

struct WalletView: View {
    
    @State var viewState = CGSize.zero
    @State var isDragging = false
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                
                HStack(spacing: 20) {
                    ImageBook.flow
                        .renderingMode(.original)
                        .shadow(color: Color(hex:"000000").opacity(0.5),
                                radius: 20, x: 10, y: 5)
                    
                    VStack(alignment: .leading) {
                        Text("Account")
                            .font(.title2)
                        Text("lilico.fn")
                            .foregroundColor(.secondary)
                            .font(.body)
                    }
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "eye.fill")
                            .foregroundColor(Color.primary)
                            .padding()
                            .cornerRadius(10)
                            .modifier(OutlineModifier(cornerRadius: 5))
                            
                    }
                }
                
                HStack {
                    Text("89.45")
                        .font(.title, weight: .bold)
//                        .blendMode(.luminosity)
                    Text("Flow")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                
                Text("0x123123123")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .modifier(OutlineOverlay(cornerRadius: 20))
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color.LL.rebackground.opacity(0.1))
                    .offset(x: viewState.width/25, y: viewState.height/25)
            }
            .padding()
            .scaleEffect(isDragging ? 0.9 : 1)
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
            .rotation3DEffect(Angle(degrees: 5), axis: (x: viewState.width, y: viewState.height, z: 0))
            .gesture(
                DragGesture().onChanged { value in
                    self.viewState = value.translation
                    self.isDragging = true
                }
                .onEnded { value in
                    self.viewState = .zero
                    self.isDragging = false
                }
            )
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.LL.background.edgesIgnoringSafeArea(.all))
//        .navigationBarTitleDisplayMode(.inline)
//        .hideNavigationBar()
        
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .colorScheme(.dark)
        WalletView()
    }
}
