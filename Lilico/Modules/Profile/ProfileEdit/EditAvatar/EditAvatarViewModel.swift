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
    }
}

extension EditAvatarView {
    class EditAvatarViewModel: ObservableObject {
        @Published var mode: Mode = .preview
        @Published var items: [AvatarItemModel]
        @Published var selectedItemId: String?
        
        init(items: [AvatarItemModel]) {
            self.items = items
        }
        
        func save() {
            
        }
    }
}
