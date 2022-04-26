//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

struct NFTCollection: Decodable, Hashable {
    
    let logo: URL?
    let name: String
    let address: ContractAddress
    var banner: URL? = nil
    var officialWebsite: URL? = nil
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


struct NFTModel: Decodable, Hashable, Identifiable {
    let id = UUID()
    let image: URL
    let name: String
    let collections: String
}


class NFTTabViewModel: ViewModel {
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    init() {
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
        state = .init(collections: list, nfts: nfts)
        
        fetchNFTs()
    }
    
    func fetchNFTs() {
        Task {
            do {
                let request = NFTListRequest(owner: "0x2b06c41f44a05656", offset: 0, limit: 100)
                let response: NFTListResponse = try await Network.requestWithRawModel(AlchemyEndpoint.nftList(request),
                                                                                      decoder: JSONDecoder(),
                                                                                      needToken: false)
                
                let collections: [NFTCollection] =  try await Network.requestWithRawModel(GithubEndpoint.collections,
                                                      needToken: false)
                
                let groups = Dictionary(grouping: response.nfts) { nft in
                    return nft.contract
                }
                
                let haveCollections = collections.filter{ groups.keys.compactMap{ $0.address }.contains($0.address.mainnet) }
                
                await MainActor.run {
                    state.collections = haveCollections
                    state.nfts = response.nfts.compactMap({ NFTResponse in
                        
                        var url = NFTResponse.media?.first?.uri
                                            
                        
                        if url == nil , let data = NFTResponse.metadata.metadata.first{ $0.name.contains("image")} {
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
