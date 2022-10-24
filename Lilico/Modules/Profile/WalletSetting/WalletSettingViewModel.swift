//
//  WalletSettingViewModel.swift
//  Lilico
//
//  Created by Selina on 24/10/2022.
//

import SwiftUI

class WalletSettingViewModel: ObservableObject {
    func resetWalletAction() {
        UserManager.shared.reset()
    }
}
