//
//  Date.swift
//  Lilico
//
//  Created by Selina on 4/7/2022.
//

import Foundation

private let yyyyMMddFormatter = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private let MMMddFormatter = { () -> DateFormatter in
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    return formatter
}()

extension Date {
    var ymdString: String {
        return yyyyMMddFormatter.string(from: self)
    }
    
    var mmmddString: String {
        return MMMddFormatter.string(from: self)
    }
}
