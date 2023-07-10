//
//  ExtConnectivity.swift
//  Lilico
//
//  Created by Selina on 10/7/2023.
//

import Foundation

// MARK: - Defines
let ExtRequiredDataKey = "ExtRequiredDataKey"

struct SharedModel: Codable {
    let address: String
    let payer: String
    
    var isValid: Bool {
        return !address.isEmpty && !payer.isEmpty
    }
    
    static func emptyModel() -> SharedModel {
        return SharedModel(address: "", payer: "")
    }
}

enum NativeMessageType: String {
    case fetch              // extension needs required data
}

enum ExtConnectivityError: Error {
    case unknown
    case userDefaultsIsNil
}

// MARK: - Class
class ExtConnectivity {
    static let shared = ExtConnectivity()
    private init() {}
}

// MARK: - Setter
extension ExtConnectivity {
    func updateAddress(_ address: String) throws {
        let model = sharedModel ?? SharedModel.emptyModel()
        try updateSharedModel(SharedModel(address: address, payer: model.payer))
    }
    
    func updatePayer(_ payer: String) throws {
        let model = sharedModel ?? SharedModel.emptyModel()
        try updateSharedModel(SharedModel(address: model.address, payer: payer))
    }
    
    func updateSharedModel(_ model: SharedModel) throws {
        guard let ud = userDefaults() else {
            throw ExtConnectivityError.userDefaultsIsNil
        }
        
        let data = try JSONEncoder().encode(model)
        ud.set(data, forKey: ExtRequiredDataKey)
    }
}

// MARK: - Getter
extension ExtConnectivity {
    /// check if ext required data is prepared
    var isPrepared: Bool {
        guard let model = sharedModel else {
            return false
        }
        
        return model.isValid
    }
    
    var sharedModel: SharedModel? {
        do {
            guard let data = userDefaults()?.data(forKey: ExtRequiredDataKey) else {
                return nil
            }
            
            let model = try JSONDecoder().decode(SharedModel.self, from: data)
            return model
        } catch {
            log.error("convert shared model failed", context: error)
            return nil
        }
    }
}

// MARK: - Helper
extension ExtConnectivity {
    private func userDefaults() -> UserDefaults? {
        return groupUserDefaults()
    }
}
