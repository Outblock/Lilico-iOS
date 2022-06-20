//
//  ProfileEditViewModel.swift
//  Lilico
//
//  Created by Selina on 14/6/2022.
//

import SwiftUI
import Combine

extension ProfileEditViewModel {
    struct State {
        var avatar: String = ""
        var nickname: String = ""
        var isPrivate: Bool = false
    }
    
    enum Input {
        case changePrivate(Bool)
        case editAvatar
    }
}

class ProfileEditViewModel: ViewModel {
    @Published var state: State
    @Published var needShowLoadingHud: Bool = false
    @RouterObject var router: ProfileEditCoordinator.Router?
    
    private var cancellableSet = Set<AnyCancellable>()
    
    init() {
        state = State()
        UserManager.shared.$userInfo.sink { [weak self] userInfo in
            guard let userInfo = userInfo else {
                return
            }
            
            self?.state.avatar = userInfo.avatar.convertedAvatarString()
            self?.state.nickname = userInfo.nickname
            self?.state.isPrivate = userInfo.isPrivate
        }.store(in: &cancellableSet)
    }
    
    func trigger(_ input: Input) {
        switch input {
        case .changePrivate(let isPrivate):
            changePrivate(isPrivate)
        case .editAvatar:
            editAvatarAction()
        }
    }
    
    private func editAvatarAction() {
        Task {
            do {
                var items = [EditAvatarView.AvatarItemModel]()
                
                let nfts = try await NFTListCache.cache.getNFTList()
                if let currentAvatar = UserManager.shared.userInfo?.avatar {
                    items.append(EditAvatarView.AvatarItemModel(type: .string, avatarString: currentAvatar))
                }
                
                for nft in nfts {
                    items.append(EditAvatarView.AvatarItemModel(type: .nft, nft: nft))
                }
                
                if items.isEmpty {
                    HUD.error(title: "nft_empty".localized)
                    return
                }
                
                gotoAvatarEdit(items: items)
            } catch {
                DispatchQueue.main.async {
                    HUD.error(title: "fetch_nft_error".localized)
                    NFTListCache.cache.refresh()
                }
            }
        }
    }
    
    private func gotoAvatarEdit(items: [EditAvatarView.AvatarItemModel]) {
        DispatchQueue.main.async {
            self.router?.route(to: \.avatarEdit, items)
        }
    }
    
    private func changePrivate(_ isPrivate: Bool) {
        if (state.isPrivate == isPrivate) {
            return
        }
        
        needShowLoadingHud = true
        
        Task {
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.Profile.updatePrivate(isPrivate))
                DispatchQueue.main.async {
                    self.needShowLoadingHud = false
                    if response.httpCode == 200 {
                        UserManager.shared.updatePrivate(isPrivate)
                    } else {
                        HUD.error(title: "update_private_failed".localized)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.needShowLoadingHud = false
                    HUD.error(title: "update_private_failed".localized)
                }
            }
        }
    }
}
