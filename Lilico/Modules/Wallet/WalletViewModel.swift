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
    @Published var activatedCoins: [TokenModel] = []
    
    private var supportedCoins: [TokenModel] = []
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .walletHiddenFlagUpdated).sink { _ in
            DispatchQueue.main.async {
                self.refreshHiddenFlag()
            }
        }.store(in: &cancelSets)
        
        WalletManager.shared.$walletInfo.sink { [weak self] newInfo in
            if let self = self {
                DispatchQueue.main.async {
                    let needReloadWalletData = newInfo?.primaryWalletModel?.getAddress != self.address
                    
                    self.refreshWalletInfo()
                    
                    if needReloadWalletData {
                        self.fetchWalletData()
                    }
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

// MARK: - Action

extension WalletViewModel {
    
}

// MARK: - Internal

extension WalletViewModel {
    private func fetchWalletData() {
        if address == "0x0000000000000000" {
            return
        }
        
        Task {
            do {
                try await fetchAllSupportedCoins()
                try await fetchActivatedCoins()
            } catch {
                HUD.error(title: "fetch_wallet_error".localized)
            }
        }
    }
    
    private func fetchAllSupportedCoins() async throws {
        do {
            let coins: [TokenModel] = try await AppConfig.flowCoins.fetchList()
            let validCoins = coins.filter { $0.getAddress()?.isEmpty == false }
            supportedCoins = validCoins
        } catch {
            throw error
        }
    }
    
    private func fetchActivatedCoins() async throws {
        if supportedCoins.count == 0 {
            DispatchQueue.main.async {
                self.activatedCoins.removeAll()
            }
            return
        }
        
        do {
            let enabledList = try await FlowNetwork.checkTokensEnable(address: Flow.Address(hex: address), tokens: supportedCoins)
            if enabledList.count != supportedCoins.count {
                throw WalletError.fetchFailed
            }
            
            var list = [TokenModel]()
            for (index, value) in enabledList.enumerated() {
                if value == true {
                    list.append(supportedCoins[index])
                }
            }
            
            let l = list
            DispatchQueue.main.async {
                self.activatedCoins.removeAll()
                self.activatedCoins.append(contentsOf: l)
            }
        } catch {
            throw error
        }
    }
}
