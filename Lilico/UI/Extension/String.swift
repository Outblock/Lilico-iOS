//
//  String.swift
//  Lilico
//
//  Created by Hao Fu on 8/1/22.
//

import Foundation

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func matchRegex(_ regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression.init(pattern: regex, options: [])
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            return matches.count > 0
        } catch {
            return false
        }
    }
}

extension String {
    /// print object memory address
    static func pointer(_ object: AnyObject?) -> String {
        guard let object = object else { return "nil" }
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(object).toOpaque()
        return String(describing: opaque)
    }
}

