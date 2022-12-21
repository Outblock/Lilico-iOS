//
//  Network.swift
//  Lilico
//
//  Created by Hao Fu on 2/1/22.
//

import Combine
import CombineMoya
import FirebaseAuth
import Foundation
import Haneke
import Moya

public enum NetworkError: Error {
    case unAuth
    case emptyIDToken
    case decodeFailed
    case emptyData
}

enum Network {
//    var cancelllables: [AnyCancellable] = []

    struct Response<T: Decodable>: Decodable {
        let httpCode: Int
        let message: String?
        let data: T?

        enum CodingKeys: String, CodingKey {
            case httpCode = "status"
            case message
            case data
        }
    }

    struct EmptyResponse: Decodable {
        let httpCode: Int
        let message: String

        enum CodingKeys: String, CodingKey {
            case httpCode = "status"
            case message
        }
    }

    static func fetchIDToken() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return try await currentUser.getIDToken()
        }

        let result = try await Auth.auth().signInAnonymously()
        return try await result.user.getIDToken()
    }

    static func request<T: Decodable, U: TargetType>(_ target: U, decoder: JSONDecoder = LilicoAPI.jsonDecoder, needToken: Bool = true) async throws -> T {
        let token = try await fetchIDToken()
        let authPlugin = AccessTokenPlugin { _ in token }
        let logPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        let provider = MoyaProvider<U>(plugins: needToken ? [logPlugin, authPlugin] : [logPlugin])
        let result = await provider.asyncRequest(target)
        switch result {
        case let .success(response):
            do {
                let filterdResponse = try response.filterSuccessfulStatusCodes()

                let model = try decoder.decode(Response<T>.self, from: filterdResponse.data)
                
                guard let data = model.data else {
                    throw NetworkError.emptyData
                }
                return data
            } catch {
                throw error
            }
        case let .failure(error):
            throw error
        }
    }

    static func requestWithRawModel<T: Decodable, U: TargetType>(_ target: U, decoder: JSONDecoder = LilicoAPI.jsonDecoder, needToken: Bool = true) async throws -> T {
        let token = try await fetchIDToken()
        let authPlugin = AccessTokenPlugin { _ in token }
        let provider = MoyaProvider<U>(plugins: needToken ? [NetworkLoggerPlugin(), authPlugin] : [NetworkLoggerPlugin()])
        let result = await provider.asyncRequest(target)
        switch result {
        case let .success(response):
            do {
                let filterdResponse = try response.filterSuccessfulStatusCodes()
                let model = try decoder.decode(T.self, from: filterdResponse.data)
                return model
            } catch {
                throw error
            }
        case let .failure(error):
            throw error
        }
    }

//    func request<T: Codable, U: TargetType>(_ target: U) -> Future<T, Error> {
//
//        return Future { promise in
//
//            let token = try await Auth.auth().currentUser?.getIDToken()
//
//            let authPlugin = AccessTokenPlugin { result in
//                ""
//            }
//
//            let provider = MoyaProvider<U>(plugins: [NetworkLoggerPlugin(), authPlugin])
//            provider.request(target, completion: { result in
//                switch result {
//                case let .success(response):
//
//                    if let designPath = path, !designPath.isEmpty {
//                        guard let model = response.mapObject(T.self, designatedPath: designPath) else {
//                            seal.reject(MyError.DecodeFailed)
//                            return
//                        }
//                        seal.fulfill(model)
//
//                    } else {
//                        guard let model = response.mapObject(T.self) else {
//                            seal.reject(MyError.DecodeFailed)
//                            return
//                        }
//                        seal.fulfill(model)
//                    }
//
//                case let .failure(error):
//                    seal.reject(error)
//                }
//            })
//        }
//    }
}
