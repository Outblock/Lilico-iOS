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
    @Published var walletInfo: WalletResponse?
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .walletHiddenFlagUpdated).sink { _ in
            DispatchQueue.main.async {
                self.refreshHiddenFlag()
            }
        }.store(in: &cancelSets)
        
        WalletManager.shared.$walletInfo.sink { [weak self] newWalletInfo in
            if let self = self {
                DispatchQueue.main.async {
                    self.walletInfo = newWalletInfo?.primaryWalletModel
                }
            }
        }.store(in: &cancelSets)
    }
    
    private func refreshHiddenFlag() {
        isHidden = LocalUserDefaults.shared.walletHidden
    }
}

extension WalletViewModel {
    
}

extension WalletViewModel {
    
}
