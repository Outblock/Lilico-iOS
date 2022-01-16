//
//  NFTTabViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

class NFTTabViewModel: ViewModel {
    @Published
    private(set) var state: NFTTabScreen.ViewState = .init()

    init() {
        let list: [NFTCollection] = [
            .init(logo: URL(string: "https://img.rarible.com/prod/image/upload/t_avatar_big/prod-collections/0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d/avatar/QmfNrXe67J4t1EvXLxPhxTavQCLryurWFj1DDRKkjNQqit")!,
                  name: "BoredApeYachtClub"),
            .init(logo: URL(string: "https://img.rarible.com/prod/image/upload/t_avatar_big/prod-collections/0xc1caf0c19a8ac28c41fe59ba6c754e4b9bd54de9/avatar/Qmb56xhzBZkJvG3UD78XBbRkkQ2yKwMPpP56GP5bL1LbBR")!,
                  name: "CryptoSkulls")
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
    }
    
    func fetchNFTs() {
        Task {
            try {
                let request = NFTListRequest(owner: "0x2b06c41f44a05656", offset: 0, limit: 100)
                let response = await Network.request(AlchemyEndpoint.nftList(request), needToken: false)
            } catch {
                HUD.debugError(title: "Fetch NFT Error")
            }
        }
    }

    func trigger(_: NFTTabScreen.Action) {}
}
