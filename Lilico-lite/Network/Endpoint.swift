//
//  Endpoint.swift
//  Lilico-lite
//
//  Created by Hao Fu on 28/11/21.
//

import Foundation

enum HTTPMethod {
    case get
    case post
}

protocol Endpoint {
    var baseURL: URL { get set }
    var path: String { get set }
    var method: HTTPMethod { get set }
    var headers: [String: String]? { get set }
    var parameter: [String: String]? { get set }
    
}

extension Endpoint {
    var headers: [String: String]? {
        get { nil }
    }
    var parameter: [String: String]? {
        get { nil }
    }
}
