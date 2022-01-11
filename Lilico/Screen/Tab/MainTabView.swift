//
//  MainTabView.swift
//  Lilico
//
//  Created by Hao Fu on 10/1/22.
//

import SwiftUI

struct MainTabView: View {
    
    @State
    var offset: CGFloat = 0
    
    @State
    var scrollTo: CGFloat = -1
    
    var indicatorOffset: CGFloat {
        let progress = offset / screenWidth
        let maxWidth: CGFloat = (screenWidth - 40) / 4
        let value = progress * maxWidth + 20
//        + 10
//        + (progress * 2)
        
        print("offset -> \(offset), value -> \(value)")
        return value
    }
    
    var currentIndex: Int {
        let progress = round(offset / screenWidth)
        // For Saftey...
        let index = min(Int(progress), 4 - 1)
        return index
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            OffsetPageTabView(offset: $offset, scrollTo: $scrollTo) {
                HStack(spacing: 0) {
                    EmptyWalletView(viewModel: EmptyWalletViewModel().toAnyViewModel())
                        .frame(width: screenWidth)
                    
                    WalletView()
                        .frame(width: screenWidth)
                    
                    ProfileView()
                        .frame(width: screenWidth)
                    
                    ProfileView()
                        .frame(width: screenWidth)
                }
            }
            .background(Color.LL.background.edgesIgnoringSafeArea(.all))
//            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
//            .edgesIgnoringSafeArea([.bottom])
            .hideNavigationBar()
            .mask {
                Rectangle()
                    .cornerRadius([.bottomLeading, .bottomTrailing], 20)
                    .offset(y: -50)
//                    .foregroundColor(.red)
//                    .cornerRadius([.bottomLeft, .bottomRight], 20)
            }
            
            HStack(spacing: 0) {
                
                ForEach(0..<4) { index in
                    Button {
                        withAnimation(.tabSelection) {
                            scrollTo = screenWidth * CGFloat(index)
                        }
                        
                    } label: {
                        Image(systemName: currentIndex == index ? "die.face.1.fill" : "die.face.1")
                            .frame(maxWidth: .infinity, alignment: .center)
//                            .height(30)
                            .background(.LL.deepBg)
                            .padding(.vertical, 26)
                            .foregroundColor(Color.LL.text)
//                            .background(Color.green)
                    }.contextMenu(menuItems: {
                        Text("Action 1")
                        Text("Action 2")
                    })
                }
            }
            .overlay(
                Rectangle()
                    .frame(width: 28, height: 4)
                    .cornerRadius(3)
//                    .frame(width: 88)
                
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: indicatorOffset)
//                    .foregroundColor(color)
//                    .blendMode(.)
            )
            .padding(.horizontal, 20)
            .frame(width: screenWidth, height: 30, alignment: .center)
            .background(.LL.deepBg)
        }
        .background(.LL.deepBg)
        .hiddenNavigationBarStyle()
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
