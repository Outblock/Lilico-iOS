//
//  NFTAddCollectionView.swift
//  Lilico
//
//  Created by cat on 2022/6/19.
//

import SwiftUI

struct NFTAddCollectionView: View {
    var body: some View {
        
        OffsetScrollView(offset: .constant(1)) {
            VLazyScrollView {
                Section {
                    
                } header: {
                    title(title: "Trending")
                }
                
                Section {
                    
                } header: {
                    title(title: "Collection list")
                }

            }
        }
        
    }
    
    private func title(title: String) -> some View {
        return Text(title.localized.uppercased())
            .foregroundColor(.LL.Neutrals.neutrals6)
            .font(.LL.body.weight(.w600))
    }
}


extension NFTAddCollectionView {
    
    struct CollectionItem: View {
        
        var collection: NFTCollection
    
        var body: some View {
            HStack {
                HStack(alignment: .center) {
                    VStack(alignment: .leading,spacing: 4) {
                        HStack(alignment: .center) {
                            Text(collection.name)
                                .font(.LL.largeTitle3)
                                .fontWeight(.w700)
                                .foregroundColor(.LL.Neutrals.text)
                            Image("Flow")
                                .resizable()
                                .frame(width: 12, height: 12)
                            Image("arrow_right_grey")
                                .resizable()
                                .frame(width: 10, height: 10)
                        }
                        .frame(height: 26)
                        
                        Text(collection.description ?? "")
                            .font(.LL.body)
                            .fontWeight(.w400)
                            .foregroundColor(.LL.Neutrals.neutrals4)
                            .padding(.bottom, 18)
                            .frame(height: 36)
                    }
                    
                    Spacer(minLength: 88)
                    Button {
                        
                    } label: {
                        
                        Image("icon_nft_add")
                            .foregroundColor(.LL.Primary.salmonPrimary)
                            .frame(width: 26, height: 26, alignment: .center)
                            .padding(6)
                            .background(.LL.Shades.front)
                            .clipShape(Circle())
                           
                    }

                }
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
            }
            
            .background(
                ZStack {
                    HStack() {
                        Spacer()
                        Image("test_nft_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 148,alignment: .trailing)
                            
                    }
                    
                    LinearGradient(colors:
                                    [
                                        .LL.Shades.front.opacity(0.32),
                                        .LL.Shades.front.opacity(0.88),
                                        .LL.Shades.front,
                                    ],
                                   startPoint: .topLeading,
                                   endPoint: .trailing)
                    .blur(radius: 6)
                }
                    .background(
                        Color.LL.Shades.front
                    )
            )
            
            
            
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct NFTAddCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        NFTAddCollectionView.CollectionItem(collection: NFTCollection(logo: URL(string: "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg")!, name: "OVO", address: ContractAddress(mainnet: "", testnet: ""), banner: nil, officialWebsite: nil, marketplace: nil, description: "hhhhhhhh", path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: "")))
            .previewLayout(.sizeThatFits)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9)
            )
    }
}

