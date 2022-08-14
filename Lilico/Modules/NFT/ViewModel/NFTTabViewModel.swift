//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Haneke
import Kingfisher

import SwiftUIX

extension NFTTabScreen {
    enum ViewStyle {
        case normal
        case collectionList
        case grid
        
        var desc: String {
            switch self {
            case .normal:
                return "List"
            case .grid:
                return "Grid"
            default:
                return ""
            }
        }
    }
    
    struct ViewState {
        var style: NFTTabScreen.ViewStyle = .normal
        var selectedIndex = 0
        var loading: Bool = false
        var collections: [NFTCollection] = []
        var items: [CollectionItem] = []
        
        var gridNFTs: [NFTModel] = []
        var gridIsEnd: Bool = false
        var gridIsLoading: Bool = false
        var gridInitRequested: Bool = false
        
        var colorsMap: [String: [Color]] = [:]
        var isEmpty: Bool {
            return !loading && items.count == 0
        }
    }

    enum Action {
        case search
        case add
        case info(NFTModel)
        case collection(CollectionItem)
        case fetchColors(String)
        case back
    }
}

class NFTTabViewModel: ViewModel {
    @Published var state: NFTTabScreen.ViewState = .init()

    /*
     0x2b06c41f44a05656
     0xccea80173b51e028
     0x53f389d96fb4ce5e
     0x01d63aa89238a559
     0x050aa60ac445a061
     0xadca05d078ebf98a
     */
    private var owner: String = "0x01d63aa89238a559"

    init() {
        
//        refreshListAction(isFromCache: true)
        // TODO: - Use Cache
        refreshCollectionAction()
    }

    func trigger(_ input: NFTTabScreen.Action) {
        switch input {
        case let .info(model):
            Router.route(to: RouteMap.NFT.detail(self, model))
        case .search:
            break
        case .add:
            Router.route(to: RouteMap.NFT.addCollection(self))
        case let .collection(item):
            Router.route(to: RouteMap.NFT.collection(self, item))
        case let .fetchColors(url):
            fetchColors(from: url)
        case .back:
            Router.pop()
        }
    }
}

// MARK: - List Style

extension NFTTabViewModel {
    func refreshCollectionAction(isFromCache: Bool = false) {
        if state.loading {
            return
        }
        
        state.loading = true
        state.style = .normal
        changeSelectIndexAction(index: 0)
        
        Task {
            do {
                var collecitons = try await requestCollections()
                collecitons.sort {
                    if $0.count == $1.count {
                        return $0.collection.contractName < $1.collection.contractName
                    }
                    
                    return $0.count > $1.count
                }
                
                var items = [CollectionItem]()
                for collection in collecitons {
                    let item = CollectionItem()
                    item.address = owner
                    item.name = collection.collection.contractName
                    item.count = collection.count
                    item.collection = collection.collection
                    
                    items.append(item)
                }
                
                DispatchQueue.main.async {
                    self.state.collections = collecitons
                    self.state.items = items
                    self.state.loading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.state.loading = false
                }
                
                // TODO: - Error View
                HUD.error(title: "request_failed".localized)
            }
        }
    }
    
    func changeSelectIndexAction(index: Int) {
        state.selectedIndex = index
    }
    
    func currentCollectionItem() -> CollectionItem? {
        if state.selectedIndex >= state.items.count {
            return nil
        }
        
        return state.items[state.selectedIndex]
    }
    
    private func requestCollections() async throws -> [NFTCollection] {
        let response: Network.Response<[NFTCollection]> = try await Network.requestWithRawModel(LilicoAPI.NFT.collections(owner))
        if let list = response.data {
            return list
        } else {
            return []
        }
    }
}

// MARK: - Grid Style

extension NFTTabViewModel {
    private func requestGrid(offset: Int, limit: Int = 24) async throws -> [NFTModel] {
        let request = NFTGridDetailListRequest(address: owner, offset: offset, limit: limit)
        let response: Network.Response<NFTListResponse> = try await Network.requestWithRawModel(LilicoAPI.NFT.gridDetailList(request))
        
        guard let nfts = response.data?.nfts else {
            return []
        }
        
        let models = nfts.map { NFTModel($0, in: nil) }
        return models
    }
    
    func refreshGridAction(isFromCache: Bool = false, completion: @escaping (Bool) -> ()) {
        if state.gridIsLoading {
            return
        }
        
        state.gridInitRequested = true
        state.gridIsLoading = true
        
        Task {
            do {
                let nfts = try await requestGrid(offset: 0)
                DispatchQueue.main.async {
                    self.state.gridNFTs.removeAll()
                    self.appendNFTsNoDuplicated(nfts)
                    self.state.gridIsEnd = false
                    self.state.gridIsLoading = false
                    completion(true)
                }
            } catch {
                // TODO: - Error View
                HUD.error(title: "request_failed".localized)
                DispatchQueue.main.async {
                    self.state.gridIsLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func loadMoreGridAction(completion: @escaping (Bool) -> ()) {
        if state.gridIsLoading {
            return
        }
        
        state.gridIsLoading = true
        
        Task {
            do {
                let offset = self.state.gridNFTs.count
                let limit = 24
                let nfts = try await requestGrid(offset: offset, limit: limit)
                
                let isEnd = nfts.count < limit
                
                DispatchQueue.main.async {
                    self.appendNFTsNoDuplicated(nfts)
                    self.state.gridIsEnd = isEnd
                    self.state.gridIsLoading = false
                    completion(true)
                }
            } catch {
                HUD.error(title: "request_failed".localized)
                DispatchQueue.main.async {
                    self.state.gridIsLoading = false
                    completion(false)
                }
            }
        }
    }
    
    private func appendNFTsNoDuplicated(_ newNFTs: [NFTModel]) {
        for nft in newNFTs {
            let exist = state.gridNFTs.first { $0.id == nft.id }
            
            if exist == nil {
                state.gridNFTs.append(nft)
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

    private func colors(from url: String) async {
        return await withCheckedContinuation { continuation in
            ImageCache.default.retrieveImage(forKey: url) { [self] result in
                switch result {
                case let .success(value):
                    Task {
                        let colors = await value.image!.colors()

                        DispatchQueue.main.async {
                            self.state.colorsMap[url] = colors
                            continuation.resume()
                        }
                    }

                case .failure:
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
    static func testCollection() -> CollectionItem {
        let nftModel = testNFT()
        let model = CollectionItem()
        return model
    }

    static func testNFT() -> NFTModel {
        let nftJsonData = """
        {
                        "contract": {
                            "address": "0x2d2750f240198f91",
                            "contractMetadata": {
                                "publicCollectionName": "MatrixWorldFlowFestNFT.MatrixWorldFlowFestNFTCollectionPublic",
                                "publicPath": "MatrixWorldFlowFestNFT.CollectionPublicPath",
                                "storagePath": "MatrixWorldFlowFestNFT.CollectionStoragePath"
                            },
                            "externalDomain": "matrixworld.org",
                            "name": "MatrixWorldFlowFestNFT"
                        },
                        "description": "a patrol code block for interacting with objects, 930/1500",
                        "externalDomainViewUrl": "matrixworld.org",
                        "id": {
                            "tokenId": "929",
                            "tokenMetadata": {
                                "uuid": "60564528"
                            }
                        },
                        "media": [
                            {
                                "mimeType": "image",
                                "uri": "https://storageapi.fleek.co/124376c1-1582-4135-9fbb-f462a4f1403c-bucket/logo-10.png"
                            }
                        ],
                        "metadata": {
                            "metadata": [
                                {
                                    "name": "type",
                                    "value": "common"
                                },
                                {
                                    "name": "hash",
                                    "value": ""
                                }
                            ]
                        },
                        "postMedia": {
                            "description": "a patrol code block for interacting with objects, 930/1500",
                            "image": "https://storageapi.fleek.co/124376c1-1582-4135-9fbb-f462a4f1403c-bucket/logo-10.png",
                            "title": "Patrol Code Block"
                        },
                        "title": "Patrol Code Block"
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
        let response = try! jsonDecoder.decode(NFTResponse.self, from: nftJsonData)
        let collModel = try! jsonDecoder.decode(NFTCollectionInfo.self, from: collJsonData)
        return NFTModel(response, in: collModel)
    }
}
