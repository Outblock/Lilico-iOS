//
//  NFTCollectionEnableView.swift
//  Lilico
//
//  Created by cat on 2022/6/27.
//

import SwiftUI
import Kingfisher

extension NFTAddCollectionView {
    
    
    struct NFTCollectionEnableView: View {
        
        var item: NFTCollectionItem
        
        @Binding var isPresented: Bool
        
        @State private var showButton = true
        @State private var offset: CGFloat = 0
        @State private var topOpacity: CGFloat = 0.72;
        
        var body: some View {
            VStack(spacing: 0) {
                HStack{
                    HStack{}
                        .frame(width: 36, height: 36)
                    Spacer()
                    Text("confirmation".localized)
                        .font(.inter(size: 18,weight: .w700))
                    Spacer()
                    Button {
                        isPresented.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color.LL.Neutrals.neutrals8)
                    }
                    .frame(width: 36, height: 36)
                }
                .padding(.top, 16)
                
                ZStack(alignment: .topLeading) {
                    HStack(alignment: .top,spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center,spacing: 6) {
                                Text(item.collection.name)
                                    .font(.LL.largeTitle3)
                                    .fontWeight(.w700)
                                    .foregroundColor(.LL.Neutrals.text)
                                Image("Flow")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                            }
                            
                            //TODO: Platform name
                            Text("Platform name")
                                .font(.LL.body)
                                .fontWeight(.w400)
                                .foregroundColor(.LL.Neutrals.text)
                            
                            Spacer()
                            Text("Desc")
                                .font(.LL.body,weight: .w400)
                                .foregroundColor(.LL.Neutrals.neutrals7)
                                .padding(.trailing, 98)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack {
                            Text(item.processName())
                                .font(Font.inter(size: 12, weight: .w600))
                                .foregroundColor(.LL.Primary.salmonPrimary)
                                .frame(height: 24)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 2)
                                .background(Color.LL.Primary.salmon5)
                                .cornerRadius(24)
                                .opacity(item.processName().isEmpty ? 0 : 1)
                                .animation(.easeInOut, value: item.processName())
                        }
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity, maxHeight: (screenWidth-38)/1.4)
                .background(
                    ZStack {
                        HStack {
                            Spacer()
                            KFImage
                                .url(item.collection.logoURL)
                                .placeholder({
                                    Image("placeholder")
                                        .resizable()
                                })
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: (screenWidth-38)/1.4,
                                       height: (screenWidth-38)/1.4)
                        }
                        LinearGradient(colors:
                                        [
                                            .LL.Shades.front,
                                            .LL.Shades.front,
                                            .LL.Shades.front.opacity(0.88),
                                            .LL.Shades.front.opacity(0.32),
                                        ],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                        
                        
                    }
                        .blur(radius: 6)
                )
                .cornerRadius(16)
                .padding(.top, 22)
                
                if(item.status == .idle) {
                    Button {
                        //TODO: enable
                    } label: {
                        Text("enable_collection".localized)
                            .foregroundColor(.LL.Button.text)
                            .font(.body)
                            .fontWeight(.w700)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 54)
                    .background(Color.LL.Button.color)
                    .cornerRadius(12)
                    .padding(.top, 36)
                }
            }
            .padding(.horizontal, 18)
            .background(Color.LL.Neutrals.background.opacity(0.9))
         
        }
        
    }
    
}


struct NFTCollectionEnableView_Previews: PreviewProvider {
    static let item = NFTCollectionItem(collection: NFTCollectionInfo(logo: "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg", name: "OVO", contractName: "", address: ContractAddress(mainnet: "", testnet: ""), secureCadenceCompatible: SecureCadenceCompatible(mainnet: true, testnet: true), banner: nil, officialWebsite: nil, marketplace: nil, description: "hhhhhhhh", path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: "")))
    
    static var previews: some View {
        NFTAddCollectionView.NFTCollectionEnableView(item: item, isPresented: .constant(true))
            
    }
}
