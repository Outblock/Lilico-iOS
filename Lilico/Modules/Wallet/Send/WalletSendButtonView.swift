//
//  WalletSendButtonView.swift
//  Lilico
//
//  Created by Hao Fu on 1/9/2022.
//

import SwiftUI

struct WalletSendButtonView: View {
    
    @GestureState
    var tap = false
    
    @State
    var press = false
    
    @State
    var isLoading: Bool = false
    
    var buttonText: String = "hold_to_send".localized
    
    var action: () -> ()
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(
                        Color.LL.outline.opacity(0.3),
                        lineWidth: 4
                    )
                Circle()
                    .trim(from: tap ? 0.001 : 1, to: 1)
                    .stroke(
                        Color.LL.outline,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .rotation3DEffect(Angle(degrees: -180), axis: (x: 0, y: 1, z: 0))
                    // Magic HERE !
                    .animation(.easeInOut)
                    .visible(!isLoading)
                
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        Color.LL.outline,
                        style: StrokeStyle(
                            lineWidth: 4,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .rotation3DEffect(Angle(degrees: -180), axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                    .visible(isLoading)
                
            }
            .frame(width: 25, height: 25)
            Text(buttonText)
                .foregroundColor(Color.LL.Button.text)
                .font(.inter(size: 14, weight: .bold))
                .allowsHitTesting(false)
        }
        .frame(height: 54)
        .frame(maxWidth: .infinity)
        .background(Color.LL.Button.color)
        .cornerRadius(12)
        .scaleEffect(tap ? 0.95 : 1)
        .gesture(
            LongPressGesture().updating($tap) { currentState, gestureState, transaction in
                gestureState = currentState
            }
                .onEnded { value in
                    self.press.toggle()
                    self.isLoading = true
                    
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    
                    action()
                }
        )
        .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: tap)
        //            .buttonStyle(ScaleButtonStyle())
        
    }
}

class MyAnimations: NSObject, ObservableObject {
    @Published var progress: Double = 0
    
    private var displaylink: CADisplayLink!       // << here !!
    func createDisplayLink() {
        if nil == displaylink {
            displaylink = CADisplayLink(target: self, selector: #selector(step))
            displaylink.add(to: .main, forMode: .common)
        }
    }
    
    @objc func step(link: CADisplayLink) {
        progress += 0.05
    }
    
    func stop() {
        if displaylink != nil {
            displaylink.invalidate()
        }
    }
    
}

struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.linear(duration: 0.2), value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
    }
}


struct WalletSendButtonView_Previews: PreviewProvider {
    static var previews: some View {
        WalletSendButtonView{}
            .previewLayout(.sizeThatFits)
    }
}
