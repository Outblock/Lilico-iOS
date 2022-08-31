//
//  WalletSendButtonView.swift
//  Lilico
//
//  Created by Hao Fu on 1/9/2022.
//

import SwiftUI

struct WalletSendButtonView: View {
    
    @ObservedObject var animation = MyAnimations()
    
    @GestureState
    var press = false
    
    @State
    var isLoading: Bool = false
    
    @State
    var loadingProgress: Double = 0.3
    
    var body: some View {
        
            Button {
                
                if !press {
                    animation.stop()
                    animation.progress = 0
                }
                
            } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .stroke(
                                    Color.LL.outline.opacity(0.3),
                                    lineWidth: 4
                                )
                            Circle()
                                .trim(from: 0, to: isLoading ? loadingProgress : loadingProgress)
                                .stroke(
                                    Color.LL.outline,
                                    style: StrokeStyle(
                                        lineWidth: 4,
                                        lineCap: .round
                                    )
                                )
                                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
//                                .rotationEffect(.degrees(-90))
                            // 1
                                .animation(.easeOut, value: animation.progress)
                            
                        }
                        .frame(width: 20, height: 20)
                        .allowsHitTesting(false)
                        
                        Text("send".localized)
                            .foregroundColor(Color.LL.Button.text)
                            .font(.inter(size: 14, weight: .bold))
                            .allowsHitTesting(false)
                    }
//                .simultaneousGesture(
//                    LongPressGesture(minimumDuration: 0.1)
//                        .updating($press, body: { currentState, gestureState, transaction in
//
////                            if animation.progress == 0 {
//                                animation.createDisplayLink()
////                            }
//
//                        })
//                        .onEnded({ value in
//                            animation.stop()
//                            animation.progress = 0
//                        })
//                )
                .animation(.easeInOut, value: animation.progress)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background(Color.LL.Button.color)
                .cornerRadius(12)
            }
            .buttonStyle(ScaleButtonStyle())
            .animation(.easeInOut, value: animation.progress)
            .onAppear() {
                self.isLoading = true
            }
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
        WalletSendButtonView()
    }
}
