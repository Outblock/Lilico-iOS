//
//  NotificationDefine.swift
//  Lilico
//
//  Created by Selina on 21/6/2022.
//

import Foundation

public extension Notification.Name {
    static let walletHiddenFlagUpdated = Notification.Name("walletHiddenFlagUpdated")
    static let quoteMarketUpdated = Notification.Name("quoteMarketUpdated")
    static let coinSummarysUpdated = Notification.Name("coinSummarysUpdated")
    static let addressBookDidAdd = Notification.Name("addressBookDidAdd")
    static let addressBookDidEdit = Notification.Name("addressBookDidEdit")
}
