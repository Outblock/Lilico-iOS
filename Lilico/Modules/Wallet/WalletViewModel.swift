//
//  WalletViewModel.swift
//  Lilico
//
//  Created by cat on 2022/5/7.
//

import Foundation
import SwiftUI
import Flow
import Combine

class WalletViewModel : ObservableObject {
    @Published var isHidden: Bool = LocalUserDefaults.shared.walletHidden
    @Published var walletName: String = "wallet".localized
    @Published var address: String = "0x0000000000000000"
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .walletHiddenFlagUpdated).sink { _ in
            DispatchQueue.main.async {
                self.refreshHiddenFlag()
            }
        }.store(in: &cancelSets)
        
        WalletManager.shared.$walletInfo.sink { [weak self] _ in
            if let self = self {
                DispatchQueue.main.async {
                    self.refreshWalletInfo()
                }
            }
        }.store(in: &cancelSets)
    }
    
    private func refreshHiddenFlag() {
        isHidden = LocalUserDefaults.shared.walletHidden
    }
    
    private func refreshWalletInfo() {
        if let walletInfo = WalletManager.shared.walletInfo?.primaryWalletModel {
            walletName = walletInfo.getName ?? "wallet".localized
            address = walletInfo.getAddress ?? "0x0000000000000000"
        }
    }
}

extension WalletViewModel {
    
}

extension WalletViewModel {
    
}
