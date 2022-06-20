//
//  NFTFavoriteStore.swift
//  Lilico
//
//  Created by cat on 2022/5/25.
//

import Foundation
import Haneke

class NFTFavoriteStore: ObservableObject {
    
    @Published
    var favorites: [NFTModel] = []
    
    
    static let shared = NFTFavoriteStore()
    private init() {}
    
    /*
     1. fetch all
     2. add one
     3. save
     4. remove one
     */
    private var favoriteKey: String {
        let uid = UserManager.shared.getUid() ?? "0"
        return "\(uid)_favorite"
    }
    
    func loadFavorite() async  {
        return await withCheckedContinuation { continuation in
            let share = Shared.dataCache
            share.fetch(key: favoriteKey).onSuccess {[self] json in
                do {
                    let jsonDecoder = JSONDecoder()
                    self.favorites = try jsonDecoder.decode([NFTModel].self, from: json)
                    print("===== Favorites: \(self.favorites)")
                    continuation.resume()
                }catch {
                    print("====== Decoder Favorite failed")
                    continuation.resume()
                }
            }.onFailure { error in
                continuation.resume()
            }
        }
    }
    
    private func saveFavorite() {
        do {
            let share = Shared.dataCache
            let jsonEncode = JSONEncoder()
            let json = try jsonEncode.encode(favorites)
            share.set(value: json, key: favoriteKey)
            
        }catch {
            print("====== Encode Favorite failed")
        }
        
    }
    
    func addFavorite(_ nft: NFTModel) {
        favorites.append(nft)
        saveFavorite()
        print("====== Add \(favorites.count)")
        
    }
    
    func removeFavorite(_ nft: NFTModel) {
        favorites.removeAll(where: { $0.response.id.tokenID == nft.response.id.tokenID })
        saveFavorite()
        print("====== remove \(favorites.count)")
        
    }
    
}

extension NFTFavoriteStore {
    
    var isNotEmpty: Bool {
        return favorites.count > 0
    }
    
    
    func find(with id: String) -> NFTModel? {
        return favorites.first { $0.id == id }
    }
    
    func isFavorite(with nft: NFTModel) -> Bool {
        return (find(with: nft.id) != nil ? true : false)
    }
}
