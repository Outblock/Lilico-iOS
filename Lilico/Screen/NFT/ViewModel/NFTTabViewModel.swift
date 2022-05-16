//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import SwiftUIX

struct NFTCollection: Decodable, Hashable {
    let logo: URL?
    let name: String
    let address: ContractAddress
    var banner: URL? = nil
    var officialWebsite: String?
    var marketplace: URL?
    var description: String?
    var path: ContractPath
}

struct ContractAddress: Decodable, Hashable {
    let mainnet: String
    let testnet: String?
}

struct ContractPath: Decodable, Hashable {
    let storagePath: String
    let publicPath: String
    let publicCollectionName: String
}


struct NFTModel: Codable, Hashable, Identifiable {
    var id = UUID()
    let image: URL
    let name: String
    let collections: String
}

struct CollectionItem: Hashable {
    var name: String
    var count: Int
    var collection: NFTCollection
    var nfts: [NFTModel] = []
    
}

class NFTTabViewModel: ViewModel {
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    init() {
        fetchNFTs()
    }
    
    func fetchNFTs() {
        Task {
            do {
                let request = NFTListRequest(owner: "0x2b06c41f44a05656", offset: 0, limit: 100)
                let response: NFTListResponse = try await Network.requestWithRawModel(AlchemyEndpoint.nftList(request),
                                                                                      decoder: JSONDecoder(),
                                                                                      needToken: false)
                
                let collections: [NFTCollection] = try await Network.requestWithRawModel(GithubEndpoint.collections,
                                                      needToken: false)
                
                //TODO: nft.contract  NFTCollection.name
                let groups = Dictionary(grouping: response.nfts) { nft in
                    return nft.contract.address + (nft.contract.name ?? "")
                }
                
                let groupAllKey = groups.keys.compactMap{ $0}
                print(groupAllKey)
                let haveCollections = collections.filter{ item in
                    let key = item.address.mainnet+item.name
                    print(key)
                    return groupAllKey.contains(key)
                }
                print("====")
                await MainActor.run {
                    state.collections = haveCollections
                    state.nfts = response.nfts.compactMap({ NFTResponse in
                        
                        var url = NFTResponse.media?.first?.uri
                        if url == nil , let data = NFTResponse.metadata.metadata.first(where: { $0.name.contains("image")}) {
                            url = data.value
                        }
                        
                        if url != nil  {
                            url = url!.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
                        }

                        if url == "" {
                            url = "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png"
                        }
                        
                        return NFTModel(image: URL(string: url ?? "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png" )!,
                                        name: NFTResponse.contract.name ?? "" + " #" + NFTResponse.id.tokenID,
                                        collections: NFTResponse.contract.name ?? "")
                    })
                    
                    state.items = haveCollections.map{ collection -> CollectionItem in
                        
                        let theNFT = groups[collection.address.mainnet+collection.name]?.filter{ nft in
                            let res = collection.address.mainnet == nft.contract.address
                            return res
                        } ?? []
                        
                        let nft = theNFT.first
                        let nfts:[NFTModel] = theNFT.compactMap({ NFTResponse in
                            
                            var url = NFTResponse.media?.first?.uri
                            if url == nil , let data = NFTResponse.metadata.metadata.first(where: { $0.name.contains("image")}) {
                                url = data.value
                            }
                            
                            if url != nil  {
                                url = url!.replacingOccurrences(of: "ipfs://", with: "https://ipfs.io/ipfs/")
                            }
                            
                            if url == "" {
                                url = "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png"
                            }
                            
                            return NFTModel(image: URL(string: url ?? "https://talentclick.com/wp-content/uploads/2021/08/placeholder-image.png" )!,
                                            name: NFTResponse.contract.name ?? "" + " #" + NFTResponse.id.tokenID,
                                            collections: NFTResponse.contract.name ?? "")
                        })
                        let bag = CollectionItem(name:nft?.contract.name ?? "" , count: theNFT.count, collection: collection, nfts: nfts)
                        return bag
                    }.sorted{$0.count > $1.count}
                }
                print(groups)
                
            } catch let error {
                print(error)
                HUD.debugError(title: "Fetch NFT Error")
            }
        }
    }
    
    func trigger(_: NFTTabScreen.Action) {}
}

@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case let .some(value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}


extension NFTTabViewModel {
    static func testData() -> NFTTabViewModel{
        let model = NFTTabViewModel()
        let list: [NFTCollection] = [
            .init(logo: URL(string: "https://img.rarible.com/prod/image/upload/t_avatar_big/prod-collections/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d/avatar/QmfNrXe67J4t1EvXLxPhxTavQCLryurWFj1DDRKkjNQqit")!,
                  name: "BoredApeYachtClub",
                  address: .init(mainnet: "", testnet: ""),
                  path: .init(storagePath: "", publicPath: "", publicCollectionName: "")),
            .init(logo: URL(string: "https://img.rarible.com/prod/image/upload/t_avatar_big/prod-collections/0xc1caf0c19a8ac28c41fe59ba6c754e4b9bd54de9/avatar/Qmb56xhzBZkJvG3UD78XBbRkkQ2yKwMPpP56GP5bL1LbBR")!,
                  name: "CryptoSkulls",
                  address: .init(mainnet: "", testnet: ""),
                  path: .init(storagePath: "", publicPath: "", publicCollectionName: ""))
        ]
        
        let nfts: [NFTModel] = [
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:6302/dd4f5347")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:4284/1421a7b3")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:4494/e3c66f42")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:2282/fcf85b9d")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:7504/8c1ec72a")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            
        ]
        model.state = .init(collections: list, nfts: nfts)
        model.state.items = [CollectionItem(name: "A", count: 3, collection: list.first!, nfts: nfts),
                       CollectionItem(name: "A", count: 6, collection: list.last!, nfts: nfts),]
        return model
    }
    
    static func testNFTs() -> [NFTModel]{
        let nfts: [NFTModel] = [
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:6302/dd4f5347")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:4284/1421a7b3")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:4494/e3c66f42")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:2282/fcf85b9d")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            .init(image: .init(string: "https://img.rarible.com/prod/image/upload/t_image_preview/prod-itemImages/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d:7504/8c1ec72a")!,
                  name: "BoredApeYachtClub #6302",
                  collections: "BoredApeYachtClub"),
            
        ]
        return nfts
    }
}
