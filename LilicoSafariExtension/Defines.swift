//
//  Defines.swift
//  LilicoSafariExtension
//
//  Created by Selina on 7/7/2023.
//

import Foundation

let AppGroupName = "group.io.outblock.lilico"
func groupUserDefaults() -> UserDefaults? {
    return UserDefaults(suiteName: AppGroupName)
}
