//
//  FileStorage.swift
//  Lilico
//
//  Created by cat on 2022/5/13.
//

import Foundation
import SwiftUIX

@propertyWrapper
struct JSONStorage<T: Codable> {
    var value: T?
    let key: String
    //TODO: fileName: {userId_filename}, Haneke
    init(key: String) {
        self.key = key
        if let jsonData = UserDefaults.standard.data(forKey: key){
            let decoder = JSONDecoder()
            value = try? decoder.decode(T.self, from: jsonData)
        }
    }
    
    var wrappedValue: T? {
        set {
            value = newValue
            if let json = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(json, forKey: key)
            }
        }
        get {
            value
        }
        
    }
}

@propertyWrapper
struct JSONTestReader<T: Codable> {
    var value: T?
    let fileName: String
    init(fileName: String) {
        self.fileName = fileName
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let url = try URL(fileURLWithPath: path)
                let jsonData = try Data.init(contentsOf: url)
                let decoder = JSONDecoder()
                value = try? decoder.decode(T.self, from: jsonData)
            }
            catch {}
        }
    }
    
    var wrappedValue: T? {
        set {
            value = newValue
        }
        get {
            value
        }
        
    }
}
