//
//  NFTTabScreen.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import SwiftUI
// Make sure you added this dependency to your project
// More info at https://bit.ly/CVPagingLayout
import CollectionViewPagingLayout
import Kingfisher

extension NFTTabScreen {
    
    struct ViewState {
        var collections: [NFTCollection] = []
        var nfts: [NFTModel] = []
    }
    
    enum Action {
        case search
        case tapNFT
        
    }
}

struct NFTTabScreen: View {
    
    // Replace with your data
    struct Item: Identifiable {
        let id: UUID = .init()
        let number: Int
    }
    
    let items = Array(0..<10).map {
        Item(number: $0)
    }
    
    @StateObject
    var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    
    // Use the options to customize the layout
    //    var options: StackTransformViewOptions {
    //         .layout(.perspective)
    //     }
    
    var options = StackTransformViewOptions(
        scaleFactor: 0.10,
        minScale: 0.20,
        maxScale: 0.95,
        maxStackSize: 6,
        spacingFactor: 0.1,
        maxSpacing: nil,
        alphaFactor: 0.00,
        bottomStackAlphaSpeedFactor: 0.90,
        topStackAlphaSpeedFactor: 0.30,
        perspectiveRatio: 0.30,
        shadowEnabled: true,
        shadowColor: Color.LL.rebackground.toUIColor()!,
        shadowOpacity: 0.10,
        shadowOffset: .zero,
        shadowRadius: 5.00,
        stackRotateAngel: 0.00,
        popAngle: 0.31,
        popOffsetRatio: .init(width: -1.45, height: 0.30),
        stackPosition: .init(x: 1.00, y: 0.00),
        reverse: false,
        blurEffectEnabled: false,
        maxBlurEffectRadius: 0.00,
        blurEffectStyle: .light
    )
    
    @State private var favoriteColor = 0
    
    let mockNFT = URL(string: "https://img.rarible.com/prod/image/upload/t_image_big/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:3550/dc184ae9")!
    
    let modifier = AnyModifier { request in
        var r = request
        r.setValue("APKAJYJ4EHJ62UVUHINA", forHTTPHeaderField: "CloudFront-Key-Pair-Id")
        return r
    }
    
    var nfts: [GridItem] = [
        GridItem(.adaptive(minimum: 100), spacing: 18),
        GridItem(.adaptive(minimum: 100), spacing: 18)
    ]
    
    
    var body: some View {
        
        ZStack {
            
            VStack {
                KFImage
                    .url(mockNFT)
                    .fade(duration: 0.25)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: screenWidth,
                           height: screenHeight * 0.6,
                           alignment: .topLeading)
                
                Spacer()
            }
            .blur(radius: 30, opaque: true)
            .mask(
                LinearGradient(gradient: Gradient(colors:
                                                    [Color.black, Color.clear]), startPoint: .top, endPoint: .center)
            )
            .edgesIgnoringSafeArea(.top)
            
            
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    VStack(spacing: 0) {
                        HStack {
                            Picker("", selection: $favoriteColor) {
                                Text("List").tag(0)
                                Text("Grid").tag(1)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 112, height: 32, alignment: .leading)
                            
                            Spacer()
                            
                            Button {} label: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background {
                                        Circle()
                                            .foregroundColor(.LL.outline.opacity(0.8))
                                    }
                            }
                        }
                        .padding(.horizontal, 18)
                        
                        HStack() {
                            Image(systemName: "star.fill")
                            Text("Top Selection")
                                .font(.LL.largeTitle2)
                                .semibold()
                            
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .padding(.top)
                        .foregroundColor(.white)
                        
                        StackPageView(viewModel.nfts) { nft in
                            // Build your view here
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.LL.background)
                                
                                KFImage
                                    .url(nft.image)
                                    .fade(duration: 0.25)
                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
                                    .aspectRatio(1, contentMode: .fill)
//                                    .scaledToFill()
                                    .cornerRadius(8)
                                    .padding()
                                
                            }
                        }
                        //                .numberOfVisibleItems(4)
                        .options(options)
                        // The padding around each page
                        // you can use `.fractionalWidth` and
                        // `.fractionalHeight` too
                        .pagePadding(
                            top: .absolute(18),
                            left: .absolute(18),
                            bottom: .absolute(18),
                            right: .fractionalWidth(0.22)
                        )
                        
                        .frame(width: screenWidth,
                               height: screenHeight * 0.4, alignment: .center)
                        
                    }
                    .background(LinearGradient(colors: [.clear, .LL.background],
                                               startPoint: .top, endPoint: .bottom))
                    

                    Section(header: CollectionHeader(collections: viewModel.collections)) {
                        LazyVGrid(columns: nfts, spacing: 18) {
                            ForEach(viewModel.nfts, id: \.self) { nft in
                                VStack(alignment: .leading) {
                                    
                                    
                                    KFImage
                                        .url(nft.image)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
//                                        .scaledToFill()
//                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(8)
                                        .clipped()
                                    
                                    Text(nft.name)
                                        .font(.LL.body)
                                        .semibold()
                                    
                                    Text(nft.collections)
                                        .font(.LL.body)
                                        .foregroundColor(.LL.note)
                                }
                            }
                        }
                        .padding(18)
                        .background(LinearGradient(colors: [.LL.frontColor, .LL.background], startPoint: .top, endPoint: .bottom))
                        .cornerRadius(16)
                        .padding(.bottom, 30)
                    }
                    .background(Color.LL.background, ignoresSafeAreaEdges: .all)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
            }
//            .frame(width: screenWidth, height: screenHeight, alignment: .top)
        }
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
    }
}


struct NFTTabScreen_Previews: PreviewProvider {
    static var previews: some View {
        NFTTabScreen(viewModel: NFTTabViewModel().toAnyViewModel())
            .colorScheme(.light)
    }
}


struct CollectionHeader: View {
    
    var collections: [NFTCollection]
    
    var body: some View {
        VStack {
            HStack() {
                Image(systemName: "square.stack.3d.up.fill")
                Text("\(collections.count) Collections")
                    .font(.LL.largeTitle2)
                    .semibold()
                
                Spacer()
            }
            .foregroundColor(.LL.text)
            .padding(.horizontal, 18)
            
            
            ScrollView(.horizontal, showsIndicators: false, content: {
                LazyHStack(alignment: .center, spacing: 10, content: {
                    Text("  ")
                    ForEach(collections, id: \.self) { collection in
                        
                        Button {
                            
                        } label: {
                            
                            HStack {
                                KFImage
                                    .url(collection.logo)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .background(.LL.outline)
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack {
                                        Text(collection.name)
                                            .font(.LL.body)
                                            .bold()
                                            .foregroundColor(.LL.neutrals1)
                                        
                                        Image("Flow")
                                            .resizable()
                                            .frame(width: 12, height: 12)
                                    }
                                    
                                    Text("0 Collections")
                                        .font(.LL.body)
                                        .foregroundColor(.LL.note)
                                }
                            }
                            .padding(8)
                            .background(.LL.frontColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.LL.text,
                                            lineWidth:
                                                collection.name == "BoredApeYachtClub" ? 1 : 0)
                            )
                            .shadow(color: .LL.rebackground.opacity(0.05),
                                    radius: 8, x: 0, y: 0)
                            
                        }
                    }
                    Text("  ")
                })
                    .padding(.vertical, 12)
            })
                .frame(width: screenWidth,
                       height: 56 + 24,
                       alignment: .leading)
        }
        .background(.LL.background)
    }
}
