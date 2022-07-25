//
//  NFTAddCollectionView.swift
//  Lilico
//
//  Created by cat on 2022/6/19.
//

import SwiftUI
import Kingfisher
import PartialSheet

struct NFTAddCollectionView: View {
    
    @State private var offset: CGFloat = 0
    @EnvironmentObject var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    
    @State private var isPresented = false
    
    @StateObject
    var addViewModel: AddCollectionViewModel = AddCollectionViewModel()
    
    @State private var selectItem: NFTCollectionItem?
    
    let iPhoneStyle = PSIphoneStyle(
        background: .solid(Color(uiColor: .systemBackground)),
        handleBarStyle: .none,
        cover: .enabled(Color.black.opacity(0.72)),
        cornerRadius: 10
    )
    
    var body: some View {
        VStack(spacing: 0) {
            //TODO: show page by the status: empty, loading, net error, list

            OffsetScrollView(offset: $offset) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    ForEach(addViewModel.liveList, id:\.self) { it in
                        NFTAddCollectionView.CollectionItem(item: it) { item in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
                            self.selectItem = item
                            if (self.selectItem != nil) {
                                isPresented.toggle()
                            }
                        }       
                    }
                }
            }
            .searchable(text: $addViewModel.searchQuery, prompt: "search_NFT_collection".localized)
        }
        .background(Color.LL.Neutrals.background)
        .navigationTitle("add_collection".localized)
        .navigationBarTitleDisplayMode(.inline)
        .addBackBtn {
            viewModel.trigger(.back)
        }
        .partialSheet(
            isPresented: $isPresented,
            iPhoneStyle: iPhoneStyle,
            content: {
                if let item = self.selectItem  {
                    if(isPresented ) {
                        NFTAddCollectionView.NFTCollectionEnableView(item: item, isPresented: $isPresented)
                    }
                }
            }
        )
        .attachPartialSheetToRoot()
        
    }

    private func title(title: String) -> some View {
        return Text(title.localized.uppercased())
            .foregroundColor(.LL.Neutrals.neutrals6)
            .font(.LL.body.weight(.w600))
    }
}

extension NFTAddCollectionView {
    struct CollectionItem: View {
        
        var item: NFTCollectionItem
        var onAdd: (_ item: NFTCollectionItem)->Void
        @State private var isPresented = false

        var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text(item.collection.name)
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

                    Text(item.collection.description ?? "")
                        .font(Font.inter(size: 12,weight: .w400))
                        .fontWeight(.w400)
                        .foregroundColor(.LL.Neutrals.neutrals7)
                        .padding(.bottom, 18)
                        .lineLimit(2)
                        
                }
                .padding(.leading, 18)

                Spacer(minLength: 88)
                Button {
                    onAdd(item)
                    
                } label: {
                    Image("icon_nft_add")
                        .foregroundColor(.LL.Primary.salmonPrimary)
                        .frame(width: 26, height: 26, alignment: .center)
                        .padding(6)
                        .background(.LL.Shades.front)
                        .clipShape(Circle())
                }
                .padding(.trailing, 16)
                

            }
            .frame(height: 88)
            .background(
                ZStack {
                    HStack {
                        Spacer()
                        KFImage
                            .url(item.collection.logo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 148,height: 148, alignment: .trailing)
                            .clipped()
                    }

                    LinearGradient(colors:
                        [
                            .LL.Shades.front,
                            .LL.Shades.front.opacity(0.88),
                            .LL.Shades.front.opacity(0.32),
                            
                            
                        ],
                        startPoint: .leading,
                        endPoint: .trailing)
                        
                }
                    .blur(radius: 6)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .padding(.top, 12)
            .padding(.horizontal, 18)
        
            
        }
    }
}

extension NFTAddCollectionView {
    //TODO:
    struct ErrorView: View {
        var body: some View {
            return Text("Error Net")
        }
    }
    
    struct EmptyView: View {
        var body: some View {
            return Text("Empty")
        }
    }
}

struct NFTAddCollectionView_Previews: PreviewProvider {
    
    
    
    static let item = NFTCollectionItem(collection: NFTCollection(logo: URL(string: "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg")!, name: "OVO", contractName: "", address: ContractAddress(mainnet: "", testnet: ""), secureCadenceCompatible: SecureCadenceCompatible(mainnet: true, testnet: true), banner: nil, officialWebsite: nil, marketplace: nil, description: "hhhhhhhh", path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: "")))
    
    
    
    
    static let list: [NFTCollectionItem] = [
        item
    ]
    static var previews: some View {
        NavigationView {
            NFTAddCollectionView()
        }
    }
}
