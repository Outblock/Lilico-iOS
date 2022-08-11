//
//  String.swift
//  Lilico
//
//  Created by Hao Fu on 8/1/22.
//

import Foundation
import UIKit

extension String {
    var localized: String {
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }
        
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let bundle = Bundle(path: path) else {
            return value
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        return String.localizedStringWithFormat(localized, args)
    }

    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }

    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func matchRegex(_ regex: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, count))
            return matches.count > 0
        } catch {
            return false
        }
    }

    func removePrefix(_ prefix: String) -> String {
        if starts(with: prefix) {
            if let range = range(of: prefix) {
                let startIndex = range.upperBound
                return String(self[startIndex...])
            }
        }

        return self
    }
    
    func removeSuffix(_ suffix: String) -> String {
        if hasSuffix(suffix) {
            return String(self.dropLast(suffix.count))
        }
        
        return self
    }
    
    var isNumber: Bool {
        return !isEmpty && Double.currencyFormatter.number(from: self) != nil
    }
    
    var isAddress: Bool {
        return !isEmpty && self.hasPrefix("0x") && self.count == 18
    }
    
    var hexValue: [UInt8] {
        var startIndex = self.startIndex
        return (0 ..< count / 2).compactMap { _ in
            let endIndex = index(after: startIndex)
            defer { startIndex = index(after: endIndex) }
            return UInt8(self[startIndex ... endIndex], radix: 16)
        }
    }
    
    func width(withFont font: UIFont, maxWidth: CGFloat? = nil) -> CGFloat {
        let string = self as NSString
        let attr = [NSAttributedString.Key.font: font]
        let rect = string.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attr, context: nil)
        let width = ceil(rect.size.width)
        
        if let maxWidth = maxWidth {
            return min(width, maxWidth)
        } else {
            return width
        }
    }
}

// MARK: - Firebase

extension String {
    func convertedAvatarString() -> String {
        if var comp = URLComponents(string: self) {
            if comp.host == "source.boringavatars.com" {
                comp.host = "lilico.app"
                comp.path = "/api/avatar\(comp.path)"
                return comp.url!.absoluteString
            }
        }

        if !starts(with: "https://firebasestorage.googleapis.com") {
            return self
        }

        if contains("alt=media") {
            return self
        }

        return "\(self)?alt=media"
    }
}

// MARK: - Debug

extension String {
    /// print object memory address
    static func pointer(_ object: AnyObject?) -> String {
        guard let object = object else { return "nil" }
        let opaque: UnsafeMutableRawPointer = Unmanaged.passUnretained(object).toOpaque()
        return String(describing: opaque)
    }
}
