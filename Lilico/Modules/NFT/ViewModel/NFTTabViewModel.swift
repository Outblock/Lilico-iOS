//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import SwiftUIX
import Haneke
import Kingfisher


class NFTTabViewModel: ViewModel {
    
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    private var owner: String = "0x050aa60ac445a061"
    
    @RouterObject
    var router: NFTCoordinator.Router?
    
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
                    let nfts = group.value.map { NFTModel($0, in: col) }
                        return CollectionItem(name: nft!.contract.name ?? "", count: group.value.count, collection: col, nfts: nfts)
                }
                .sorted{ $0.count > $1.count }
                await MainActor.run {
                    state.items = result
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
        let limit = 25
        var allCrudeNFTs: [NFTResponse] = []
        repeat {
            do {
                let result = try await fetchNFTList(from: offset, limit: limit)
                allCrudeNFTs.append(contentsOf: result.1)
                totalCount = result.0
                currentCount = allCrudeNFTs.count
                offset = currentCount
            }catch {
                print(error)
                HUD.debugError(title: "Fetch NFT Error")
                break;
            }
            print("获取的NFT数量：\(totalCount) | \(currentCount)")
        }
        while ( totalCount > currentCount)
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
    
    
    func trigger(_ input: NFTTabScreen.Action) {
        switch input {
        case let .info(model):
            router?.route(to: \.detail, model)
            break
        case .search:
            break
        case .add:
            break
        case let .collection(item):
            router?.route(to: \.collection, item)
        case let .fetchColors(url):
            fetchColors(from: url)
        case .back:
            DispatchQueue.main.async {
                self.router?.popLast()
            }
        }
    }
}


extension NFTTabViewModel {
    func fetchColors(from url: String) {
        if state.colorsMap[url] != nil {
            return
        }
        Task {
            await colors(from: url)
        }
    }
    
    private func colors(from url: String) async -> Void{
       return await withCheckedContinuation { continuation in
            ImageCache.default.retrieveImage(forKey: url) { [self] result in
                switch result {
                case .success( let value ):
                        Task {
                            let colors = await value.image!.colors()
                            
                            DispatchQueue.main.async {
                                self.state.colorsMap[url] = colors
                                continuation.resume()
                            }
                        }
                    
                case .failure(_):
                    continuation.resume()
                }
            }
        }
        
    }
    
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
    static func testCollection() -> CollectionItem{
        
        let nftModel = testNFT();
        let model = CollectionItem(name: "测试", count: 10, collection: nftModel.collection, nfts: [nftModel])
        return model
    }
    

    
    static func testNFT() -> NFTModel {
        let nftJsonData = """
        {
            "contract": {
                "name": "NyatheesOVO",
                "address": "0x75e0b6de94eb05d0",
                "externalDomain": "",
                "contractMetadata": {
                    "storagePath": "NyatheesOVO.CollectionStoragePath",
                    "publicPath": "NyatheesOVO.CollectionPublicPath",
                    "publicCollectionName": "NyatheesOVO.NFTCollectionPublic"
                }
            },
            "id": {
                "tokenId": "2850",
                "tokenMetadata": {
                    "uuid": "61769425"
                }
            },
            "media": [],
            "description": "Monet traveled more extensively than any other Impressionist artist in search of new motifs. His journeys to varied places including the rugged Normandy coast, the sunny Mediterranean, London, the Netherlands, and Norway inspired artworks that will be featured in the presentation. This exhibition uncovers Monet’s continuous dialogue with nature and its places through a thematic and chronological arrangement, from the first examples of artworks still indebted to the landscape tradition to the revolutionary compositions and series of his late years.",
            "metadata": {
                "metadata": [
                    {
                        "name": "metadataUrl",
                        "value": "https://www.ovo.space/api/v1/metadata/get-metadata?tokenId="
                    },
                    {
                        "name": "level",
                        "value": "1"
                    },
                    {
                        "name": "image",
                        "value": "https://ovowebpics.s3.ap-northeast-1.amazonaws.com/flowMysertybox4.png"
                    },
                    {
                        "name": "sign",
                        "value": "1"
                    },
                    {
                        "name": "hash",
                        "value": "10"
                    },
                    {
                        "name": "uri",
                        "value": "https://www.ovo.space/#/profile"
                    },
                    {
                        "name": "description",
                        "value": "Big-eating cat,  This pose is the hardest to pull off."
                    },
                    {
                        "name": "title",
                        "value": "Yellow Ranger"
                    }
                ]
            }
        }
        """.data(using: .utf8)!
        
        let collJsonData = """
        {
        "name": "OVO",
        "address": {
        "mainnet": "0x75e0b6de94eb05d0",
        "testnet": "0xacf3dfa413e00f9f"
        },
        "path": {
        "storage_path": "NyatheesOVO.CollectionStoragePath",
        "public_path": "NyatheesOVO.CollectionPublicPath",
        "public_collection_name": "NyatheesOVO.NFTCollectionPublic"
        },
        "contract_name": "NyatheesOVO",
        "logo": "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg",
        "banner": "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovobanner.png",
        "official_website": "https://www.ovo.space/#/",
        "marketplace": "https://www.ovo.space/#/Market",
        "description": "ovo (ovo space) is the industry's frst platform to issue holographic AR-NFT assets and is currently deployed on the BSC and FLOW. The NFT issued by ovo will be delivered as Super Avatars to various Metaverses and GameFi platforms."
        }
        """.data(using: .utf8)!
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        if let response = try? jsonDecoder.decode(NFTResponse.self, from: nftJsonData), let collModel = try? jsonDecoder.decode(NFTCollection.self, from: collJsonData) {
            return NFTModel(response, in: collModel)
        }
        
        return NFTModel(NFTResponse(contract: NFTContract(name: "", address: "", externalDomain: "", contractMetadata: NFTContractMetadata(storagePath: "", publicPath: "", publicCollectionName: "")), id: NFTID(tokenID: "", tokenMetadata: NFTTokenMetadata(uuid: "")), title: "", description: "", media: [], metadata: NFTMetadata(metadata: [])), in: NFTCollection(logo: nil, name: "", address: ContractAddress(mainnet: "", testnet: ""), path: ContractPath(storagePath: "", publicPath: "", publicCollectionName: "")))
        
        
    }
    
    
}
