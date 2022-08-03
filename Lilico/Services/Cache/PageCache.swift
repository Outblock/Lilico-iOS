//
//  PageCache.swift
//  Lilico
//
//  Created by Selina on 3/8/2022.
//

import SwiftUI
import Combine
import Haneke

class PageCache {
    static let cache = PageCache()
    
    private var cacheObj = Cache<Data>(name: "PageCache")
    private var cancelSet = Set<AnyCancellable>()
    
    init() {
        UserManager.shared.$isLoggedIn.sink { _ in
            if UserManager.shared.isLoggedIn == false {
                DispatchQueue.main.async {
                    self.clear()
                }
            }
        }.store(in: &cancelSet)
    }
    
    private func clear() {
        cacheObj.removeAll()
        createCache()
    }
    
    private func createCache() {
        cacheObj = Cache<Data>(name: "PageCache")
    }
}

extension PageCache {
    func set(value: Encodable, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(value)
            cacheObj.set(value: data, key: key)
        } catch {
            debugPrint("PageCache -> set failed: \(error)")
        }
    }
    
    func get<T: Decodable>(forKey key: String, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { config in
            cacheObj.fetch(key: key).onSuccess { data in
                do {
                    let result = try JSONDecoder().decode(type, from: data)
                    config.resume(returning: result)
                } catch {
                    config.resume(throwing: error)
                }
            }.onFailure { error in
                config.resume(throwing: error ?? LLError.unknown)
            }
        }
    }
}
