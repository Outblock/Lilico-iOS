//
//  TabbarItem.swift
//  Test
//
//  Created by cat on 2022/5/25.
//

import SwiftUI
import Lottie

struct TabBarItemView<T: Hashable>: View {
    var pageModel: TabBarPageModel<T>
    @Binding var selected: T
    var action: () -> Void

    var animationView: some View {
        ResizableLottieView(lottieView: pageModel.lottieView,
                            color: selected == pageModel.tag ? pageModel.color : Color.gray)
        .aspectRatio(contentMode: .fit)
        .frame(width: 30, height: 30)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) { selected = pageModel.tag }
            action()
        }, label: {
            animationView
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: selected, perform: { value in
            if value == pageModel.tag {
                pageModel.lottieView.play()
            }
        })
        .contextMenu {
            if let m = pageModel.contextMenu {
                m()
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
            ResizableLottieView(lottieView: AnimationView(name: "Coin", bundle: .main),
                                color: Color.gray)
//        LottieView(name: "Coin2", loopMode: .loop)
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 300)
            .frame(maxWidth: .infinity)
//            .contentShape(Rectangle())
            .onAppear{
                
            }
    }
}
