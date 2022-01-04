//
//  WalletView.swift
//  Lilico
//
//  Created by Hao Fu on 31/12/21.
//

import SwiftUI

struct WalletView: View {
    @StateObject
    var viewModel: AnyViewModel<EmptyWalletState, EmptyWalletAction>

    @State
    var viewState: CGSize = .zero

    @State
    var isDragging: Bool = false

    fileprivate func cardView() -> some View {
        return VStack(spacing: 50) {
            Text("Blowfish Wallet")
                .font(.headline)
                .bold()
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .offset(x: viewState.width / 30,
                        y: viewState.height / 30)

            Text("$ 1290.00")
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: viewState.width / 25,
                        y: viewState.height / 25)

            HStack {
                Button {} label: {
                    HStack {
                        Text("0x123123123")
                        Image(componentAsset: "Copy")
                    }
                }

                Spacer()

                Button {} label: {
                    Image(systemName: "eye.fill")
                }
            }.foregroundColor(.white)
                .offset(x: viewState.width / 20,
                        y: viewState.height / 20)
        }
        .padding()
        .background {
            Image(componentAsset: "Card-circle")
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
//                .background(Color(hex: "2F2F2F"))
//                .cornerRadius(20)
                .offset(x: 0, y: 30)
                .offset(x: viewState.width / 25,
                        y: viewState.height / 25)
        }
        .background(Color(hex: "2F2F2F"))
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            Image(componentAsset: "BlowFish")
                .frame(maxWidth: .infinity, alignment: .topTrailing)
                .offset(x: 20, y: -90)
                .offset(x: viewState.width / 10,
                        y: viewState.height / 10)
        }
        .shadow(color: Color(hex: "2F2F2F").opacity(0.3),
                radius: 10, x: 0, y: 0)
        .padding()
        .scaleEffect(isDragging ? 0.9 : 1)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8),
                   value: viewState)
        .rotation3DEffect(Angle(degrees: 5), axis: (x: viewState.width, y: viewState.height, z: 0))
        .gesture(
            DragGesture().onChanged { value in
                self.viewState = value.translation
                self.isDragging = true
            }
            .onEnded { _ in
                self.viewState = .zero
                self.isDragging = false
            }
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text("Wallet")
                    .font(.title)
                    .bold()
                Spacer()
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2)
            }.padding(.horizontal, 20)
                .padding(.vertical, 8)

            ScrollView {
                cardView()
                    .redacted(reason: [])
//                .shimmering()

                ActionView()

                HStack(spacing: 8) {
                    Image(componentAsset: "Flow")
                        .aspectRatio(contentMode: .fit)

                    VStack {
                        Text("Flow")
                        Text("$ 8.9")
                    }

                    Spacer()

                    VStack {
                        Text("Flow")
                        Text("$ 8.9")
                    }
                }
                .background(.clear)
            }

        }.onAppear {
//            isDraggingArray
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.LL.background.edgesIgnoringSafeArea(.all))
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
    }
}

struct ActionView: View {
    var body: some View {
        HStack(spacing: 0) {
            Button {} label: {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.up.left.circle.fill")
                        .font(.title)
                    Text("Send")
                        .font(.callout)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button {} label: {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.down.right.circle.fill")
                        .font(.title)
                    Text("Receive")
                        .font(.callout)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button {} label: {
                VStack(spacing: 5) {
                    Image(systemName: "creditcard.circle.fill")
                        .font(.title)
                    Text("Send")
                        .font(.callout)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)

            Button {} label: {
                VStack(spacing: 5) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.title)
                    Text("Swap")
                        .font(.callout)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .foregroundColor(.gray)
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(hex: "FCFCFC"))
        .cornerRadius(16)
        .padding(.horizontal)
        .shadow(color: Color(hex: "2F2F2F").opacity(0.1),
                radius: 10, x: 0, y: 0)
    }
}
