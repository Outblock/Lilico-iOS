//
//  Double.swift
//  Lilico
//
//  Created by Selina on 24/6/2022.
//

import Foundation

extension Double {
    static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 3
        f.minimumFractionDigits = 0
        return f
    }()
    
    var currencyString: String {
        let value = NSNumber(value: self).decimalValue
        return Double.currencyFormatter.string(for: value) ?? "?"
    }
}
