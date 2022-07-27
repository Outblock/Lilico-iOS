//
//  EditAvatarViewModel.swift
//  Lilico
//
//  Created by Selina on 16/6/2022.
//

import Kingfisher

import SwiftUI

extension EditAvatarView {
    enum Mode {
        case preview
        case edit
    }

    struct AvatarItemModel: Identifiable {
        enum ItemType {
            case string
            case nft
        }

        var type: ItemType
        var avatarString: String?
        var nft: NFTResponse?

        init(type: ItemType, avatarString: String? = nil, nft: NFTResponse? = nil) {
            self.type = type
            self.avatarString = avatarString
            self.nft = nft
        }

        var id: String {
            if let avatarString = avatarString {
                return avatarString
            }

            if let tokenID = nft?.id.tokenID {
                return tokenID
            } else {
                assert(false, "tokenID should not be nil")
            }

            assert(false, "AvatarItemModel id should not be nil")
            return ""
        }

        func getCover() -> String {
            if let avatarString = avatarString {
                return avatarString.convertedAvatarString()
            }

            if let nftCover = nft?.cover() {
                return nftCover
            }

            return ""
        }

        func getName() -> String {
            if type == .string {
                return "current_avatar".localized
            }

            return nft?.name() ?? " "
        }
    }
}

extension EditAvatarView {
    class EditAvatarViewModel: ObservableObject {
        @Published var mode: Mode = .preview
        @Published var items: [AvatarItemModel]
        @Published var selectedItemId: String?
        private var oldAvatarItem: AvatarItemModel?

        init(items: [AvatarItemModel]) {
            self.items = items

            if let first = items.first, first.type == .string {
                selectedItemId = first.id
                oldAvatarItem = first
            }
        }

        func currentSelectModel() -> AvatarItemModel? {
            for item in items {
                if item.id == selectedItemId {
                    return item
                }
            }

            return nil
        }

        func save() {
            guard let item = currentSelectModel() else {
                return
            }

            if let idString = oldAvatarItem?.id, item.id == idString {
                mode = .preview
                return
            }

            guard let url = URL(string: item.getCover()) else {
                HUD.error(title: "avatar_info_error".localized)
                return
            }

            let failed = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    HUD.error(title: "change_avatar_error".localized)
                }
            }

            let success: (UIImage) -> Void = { img in
                Task {
                    guard let firebaseURL = await FirebaseStorageUtils.upload(avatar: img) else {
                        failed()
                        return
                    }

                    let result = await self.uploadAvatarURL(firebaseURL)
                    if !result {
                        failed()
                        return
                    }

                    DispatchQueue.main.async {
                        HUD.dismissLoading()
                        UserManager.shared.updateAvatar(firebaseURL)
                        Router.pop()
                    }
                }
            }

            HUD.loading("saving".localized)
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case let .success(r):
                    debugPrint("EditAvatarViewModel -> save action, did get image from: \(r.cacheType)")
                    success(r.image)
                case let .failure(e):
                    debugPrint("EditAvatarViewModel -> save action, did failed get image: \(e)")
                    failed()
                }
            }
        }

        private func uploadAvatarURL(_ url: String) async -> Bool {
            guard let nickname = UserManager.shared.userInfo?.nickname else {
                return false
            }

            let request = UserInfoUpdateRequest(nickname: nickname, avatar: url)
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.Profile.updateInfo(request))
                if response.httpCode != 200 {
                    return false
                }

                return true
            } catch {
                return false
            }
        }
    }
}
