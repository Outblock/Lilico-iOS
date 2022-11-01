//
//  CurrencyListViewModel.swift
//  Lilico
//
//  Created by Selina on 31/10/2022.
//

import SwiftUI

class CurrencyListViewModel: ObservableObject {
    @Published var datas: [Currency] = Currency.allCases
    @Published var selectedCurrency: Currency = CurrencyCache.cache.currentCurrency
    
    func changeCurrencyAction(_ newCurrency: Currency) {
        if selectedCurrency == newCurrency {
            return
        }
    }
}
