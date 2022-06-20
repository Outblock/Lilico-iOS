//
//  EditAvatarViewModel.swift
//  Lilico
//
//  Created by Selina on 16/6/2022.
//

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
                return avatarString
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
            
            return nft?.title ?? ""
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
        
        func save() {
            
        }
        
        func currentSelectModel() -> AvatarItemModel? {
            for item in items {
                if item.id == selectedItemId {
                    return item
                }
            }
            
            return nil
        }
    }
}
