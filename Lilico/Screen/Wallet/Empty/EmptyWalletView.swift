//
//  EmptyWalletView.swift
//  Lilico
//
//  Created by Hao Fu on 25/12/21.
//

import SceneKit
import SPConfetti
import SwiftUI
import SwiftUIX

struct EnumeratedForEach<ItemType, ContentView: View>: View {
    let data: [ItemType]
    let content: (Int, ItemType) -> ContentView

    init(_ data: [ItemType], @ViewBuilder content: @escaping (Int, ItemType) -> ContentView) {
        self.data = data
        self.content = content
    }

    var body: some View {
        ForEach(Array(self.data.enumerated()), id: \.offset) { idx, item in
            self.content(idx, item)
        }
    }
}

struct EmptyWalletView: View {
    @StateObject
    var viewModel: AnyViewModel<EmptyWalletState, EmptyWalletAction>

    @State
    var viewStateArray: [CGSize] = [.zero, .zero]

    @State
    var isDraggingArray: [Bool] = [false, false]

    @State
    var isPresenting: Bool = false

    fileprivate func cardView(_ dataSource: CardDataSource, index: Int) -> some View {
        return VStack(spacing: 50) {
            Text(dataSource.title)
                .font(.title)
                .bold()
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .offset(x: viewStateArray[index].width / 10,
                        y: viewStateArray[index].height / 10)

            Button {
                viewModel.trigger(dataSource.action)
            } label: {
                HStack(spacing: 20) {
                    dataSource.icon
                        .foregroundColor(dataSource.iconColor)
                        .font(Font.headline.weight(.bold))
                    Text(dataSource.buttonText)
                        .foregroundColor(.black)
                        .semibold()
                }
                .font(.body)
                .padding(.horizontal, 18)
                .padding(.vertical, 15)
                .background {
                    Capsule()
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            dataSource.bgImage
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: dataSource.bgGradient,
                                   startPoint: .bottomTrailing,
                                   endPoint: .topLeading)
                )
                .cornerRadius(20)
                .offset(x: viewStateArray[index].width / 25,
                        y: viewStateArray[index].height / 25)
        }
        .padding()
        .scaleEffect(isDraggingArray[index] ? 0.9 : 1)
        .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8),
                   value: viewStateArray[index])
        .rotation3DEffect(Angle(degrees: 5), axis: (x: viewStateArray[index].width, y: viewStateArray[index].height, z: 0))
        .gesture(
            DragGesture().onChanged { value in
                self.viewStateArray[index] = value.translation
                self.isDraggingArray[index] = true
            }
            .onEnded { _ in
                self.viewStateArray[index] = .zero
                self.isDraggingArray[index] = false
            }
        )
        .onTapGesture {
            viewModel.trigger(dataSource.action)
        }
    }

//    var scene: SCNScene? = {
//        var scene = SCNScene(named: "Bitcoin_metal_coin.obj")
//        scene?.background.contents = UIColor.clear
//        return scene
//    }()
//
//    var cameraNode: SCNNode? {
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 10, z: 50)
//        return cameraNode
//    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.secondary)
                    .padding(8)
                    .overlay {
                        Circle().foregroundColor(.separator)
                    }
                Spacer()
                Image(systemName: "qrcode.viewfinder")
                    .font(.title2)
            }.padding(.horizontal, 20)
                .padding(.vertical, 8)

//            ScenekitView()
            // for user action...
            // setting custom frame...
//                .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height / 2)

            EnumeratedForEach(viewModel.dataSource) { index, dataSource in
                cardView(dataSource, index: index)
            }
        }
//        .onAppear {
//            isDraggingArray
//            isPresenting = true
//        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            NewEmptyWalletBackgroundView()
        }
        .background(Color.LL.background.edgesIgnoringSafeArea(.all))
    }
}

struct EmptyWalletView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyWalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
    }
}
