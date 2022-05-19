//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import SwiftUIX


class NFTTabViewModel: ViewModel {
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    private var owner: String = "0x2b06c41f44a05656"
    
    
    init() {
        Task {
            await refresh()
        }
    }
    
    /*
     1. fetch all nft,
     2. fetch collection
     3. group
     */
    func refresh() async{
        Task {
            print("============== refresh NFT")
            do {
                let crudeNFTList = try await handleNFTList()
                let collectionList = try await fetchCollections()
                let nftGroup = Dictionary(grouping: crudeNFTList){ $0.contract.address }
                let allCollectionKeys = collectionList.map { $0.address.mainnet }
                let result = nftGroup.filter{ nft in
                    allCollectionKeys.contains(nft.key)
                }
                .map { group -> CollectionItem in
                        let nft = group.value.first
                        let col = collectionList.first{ col in col.address.mainnet == group.key }
                        let nfts = group.value.map { NFTModel(nft: $0) }
                        return CollectionItem(name: nft!.contract.name ?? "", count: group.value.count, collection: col, nfts: nfts)
                }
                .sorted{ $0.count > $1.count }
                await MainActor.run {
                    state.items = result
                    //TODO: fetch from cache
                    state.favoriteNFTs = result.first?.nfts ?? []
                    state.loading = false
                }
            }catch {
                print(error)
                await MainActor.run {
                    state.loading = false
                }
                HUD.debugError(title: "Fetch NFT Error")
            }
        }
        
    }
    
    /// fetch all nft first.
    private func handleNFTList() async throws -> [NFTResponse]{
        var totalCount = 0
        var currentCount = 0
        var offset = 0
        let limit = 30
        var allCrudeNFTs: [NFTResponse] = []
        //TODO: 测试
        repeat {
            do {
                let result = try await fetchNFTList(from: offset, limit: limit)
                allCrudeNFTs.append(contentsOf: result.1)
                totalCount = result.0
                currentCount = allCrudeNFTs.count
                offset += limit
            }catch {
                print(error)
                HUD.debugError(title: "Fetch NFT Error")
            }
            print("获取的NFT数量：\(totalCount) | \(currentCount)")
        }
        while (totalCount > currentCount)
        return allCrudeNFTs
    }
    
    private func fetchNFTList(from offset: Int = 0, limit: Int = 30 ) async throws -> (Int, [NFTResponse]) {
        do {
            let request = NFTListRequest(owner: owner, offset: offset, limit: limit)
            let response: NFTListResponse = try await Network.requestWithRawModel(AlchemyEndpoint.nftList(request),
                                                                                  decoder: JSONDecoder(),
                                                                                  needToken: false)
            return (response.nftCount, response.nfts)
        }
        catch {
            throw error
        }
    }
    
    private func fetchCollections() async throws -> [NFTCollection] {
        do {
            let collections: [NFTCollection] = try await Network.requestWithRawModel(GithubEndpoint.collections,
                                                                                     needToken: false)
            return collections
        }
        catch {
            throw error
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
        
        
        return model
    }
    
    static func testNFTs() -> [NFTModel]{
        let nfts: [NFTModel] = [
            
        ]
        return nfts
    }
}
