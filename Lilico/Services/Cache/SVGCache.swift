//
//  SVGCache.swift
//  Lilico
//
//  Created by Selina on 24/8/2022.
//

import Foundation
import Kingfisher

class SVGCache {
    static let cache = SVGCache()
    
    func getSVG(_ url: URL) async -> String? {
        let key = url.absoluteString.md5
        
        do {
            if let data = try ImageCache.default.diskStorage.value(forKey: key) {
                let string = String(data: data, encoding: .utf8)
                return string
            }
            
            return try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let data = data else {
                        continuation.resume(throwing: LLError.unknown)
                        return
                    }
                    
                    do {
                        try ImageCache.default.diskStorage.store(value: data, forKey: key)
                        let string = String(data: data, encoding: .utf8)
                        continuation.resume(returning: string)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            return nil
        }
    }
}
