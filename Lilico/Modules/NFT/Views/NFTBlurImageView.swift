//
//  NFTBlurImageView.swift
//  Lilico
//
//  Created by cat on 2022/5/29.
//

import SwiftUI
import Kingfisher

struct NFTBlurImageView: View {
    var url: URL?
    
    var body: some View {
        VStack(alignment: .leading) {
            if(url != nil) {
                KFImage
                    .url(url)
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth, height: screenHeight * 0.6)
                    .aspectRatio(1, contentMode: .fit)
            }
            Spacer()
        }
        
        .blur(radius: 30, opaque: true)
        .background(LinearGradient(colors: [.LL.Neutrals.background.opacity(0.4), .LL.Neutrals.background.opacity(0.8)], startPoint: .top, endPoint: .bottom))
//        .mask(
//            LinearGradient(gradient: Gradient(colors:
//                                                [Color.black, Color.clear]), startPoint: .top, endPoint: .center)
//        )
    }
}

struct NFTBlurImageView_Previews: PreviewProvider {
    static var url: URL? = URL(string: "https://ovowebpics.s3.ap-northeast-1.amazonaws.com/flowMysertybox10.png")
    static var previews: some View {
        NFTBlurImageView(url: url)
    }
}
