//
//  NFTAddCollectionView.swift
//  Lilico
//
//  Created by cat on 2022/6/19.
//

import SwiftUI

struct NFTAddCollectionView: View {
    
    @State private var offset: CGFloat = 0
    @EnvironmentObject var viewModel: AnyViewModel<NFTTabScreen.ViewState, NFTTabScreen.Action>
    
    @StateObject
    var addViewModel: AddCollectionViewModel = AddCollectionViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            BackAppBar(title: "add_collection".localized) {
                
            }
            .frame(height: 44)
            //TODO: show page by the status: empty, loading, net error, list
            
            OffsetScrollView(offset: $offset) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    if addViewModel.hasTrending() {
                        Section() {
                            
                        } header: {
                            title(title: "trending")
                                .padding(.leading, 26)
                                
                        }
                    }
                    

                    Section {
                        ForEach(addViewModel.liveList, id:\.self) { it in
                            NFTAddCollectionView.CollectionItem(item: it)
                        }
                    } header: {
                        title(title: "collection_list")
                            .padding(.leading, 26)
                    }
                }
            }
        }
        .onAppear {
            
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
        
        var item: NFTCollectionItem

        var body: some View {
            HStack {
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
                            .font(.LL.body)
                            .fontWeight(.w400)
                            .foregroundColor(.LL.Neutrals.neutrals4)
                            .padding(.bottom, 18)
                            .frame(height: 36)
                    }

                    Spacer(minLength: 88)
                    Button {} label: {
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
                    HStack {
                        Spacer()
                        Image("test_nft_logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 148, alignment: .trailing)
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
    
    
    
    static let item = NFTCollectionItem(collection: NFTCollection(logo: URL(string: "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg")!, name: "OVO", contractName: "", address: ContractAddress(mainnet: "", testnet: ""), banner: nil, officialWebsite: nil, marketplace: nil, description: "hhhhhhhh", path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: "")),
                                        isAdded: false,
                                        isAdding: false)
    
    
    
    
    static let list: [NFTCollectionItem] = [
        item
    ]
    static var previews: some View {
        
        NFTAddCollectionView()
        
        NFTAddCollectionView.CollectionItem(item: item)
            .previewLayout(.sizeThatFits)
            .background(Color(red: 0.9, green: 0.9, blue: 0.9)
            )
    }
}
