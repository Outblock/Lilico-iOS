//
//  LilicoAPI.swift
//  Lilico
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation

enum LilicoAPI {
    static var jsonEncoder: JSONEncoder {
        switch self {
        default:
            let coder = JSONEncoder()
            coder.keyEncodingStrategy = .convertToSnakeCase
            return coder
        }
    }
}
