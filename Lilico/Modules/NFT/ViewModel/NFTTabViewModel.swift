//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Haneke
import Kingfisher
import Stinsen
import SwiftUIX

class NFTTabViewModel: ViewModel {
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    /*
     0x2b06c41f44a05656
     0xccea80173b51e028
     0x53f389d96fb4ce5e
     0x01d63aa89238a559
     0x050aa60ac445a061
     0xadca05d078ebf98a
     */
    private var owner: String = "0x01d63aa89238a559"

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
    func refresh() async {
        Task {
            print("============== refresh NFT")
            do {
                await NFTFavoriteStore.shared.loadFavorite()
                let crudeNFTList = try await handleNFTList()
                let collectionList: [NFTCollection] = try await FirebaseConfig.nftCollections.fetch()
                let nftGroup = Dictionary(grouping: crudeNFTList) { $0.contract.address }
                let allCollectionKeys = collectionList.map { $0.address.mainnet }
                let result = nftGroup.filter { nft in
                    allCollectionKeys.contains(nft.key)
                }
                .map { group -> CollectionItem in
                    let nft = group.value.first
                    let col = collectionList.first { col in col.address.mainnet == group.key }
                    let nfts = group.value.map { NFTModel($0, in: col) }
                    return CollectionItem(name: nft!.contract.name ?? "", count: group.value.count, collection: col, nfts: nfts)
                }
                .sorted { $0.count > $1.count }
                // if the favorite NFT is not in the NFT list,remove it.
                let favoriteList = NFTFavoriteStore.shared.favorites.filter { model in
                    crudeNFTList.first { res in
                        res.id.tokenID == model.response.id.tokenID
                    } != nil
                }

                await MainActor.run {
                    NFTFavoriteStore.shared.favorites = favoriteList
                    state.items = result
                    state.loading = false
                }
            } catch {
                print(error)
                await MainActor.run {
                    state.loading = false
                }
                HUD.debugError(title: "fetch_nft_error".localized)
            }
        }
    }

    /// fetch all nft first.
    private func handleNFTList() async throws -> [NFTResponse] {
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
            } catch {
                print(error)
                HUD.debugError(title: "fetch_nft_error".localized)
                break
            }
            print("获取的NFT数量：\(totalCount) | \(currentCount)")
        } while false
//        while ( totalCount > currentCount)
        return allCrudeNFTs
    }

    private func fetchNFTList(from offset: Int = 0, limit: Int = 25) async throws -> (Int, [NFTResponse]) {
        do {
            let request = NFTRequest(address: owner, offset: offset, limit: limit)
            let response: Network.Response<NFTListResponse> = try await Network.requestWithRawModel(LilicoAPI.NFT.list(request))
            guard let count = response.data?.nftCount, let nfts = response.data?.nfts else {
                return (0, [])
            }

            return (count, nfts)
        } catch {
            throw error
        }
    }

    func trigger(_ input: NFTTabScreen.Action) {
        switch input {
        case let .info(model):
            router?.route(to: \.detail, model)
        case .search:
            break
        case .add:
            router?.route(to: \.addCollection)
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
        let model = CollectionItem(name: "测试", count: 10, collection: nftModel.collection, nfts: [nftModel])
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
        let collModel = try! jsonDecoder.decode(NFTCollection.self, from: collJsonData)
        return NFTModel(response, in: collModel)
    }
}
