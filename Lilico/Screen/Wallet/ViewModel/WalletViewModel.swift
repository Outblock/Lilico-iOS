//
//  WalletViewModel.swift
//  Lilico
//
//  Created by cat on 2022/5/7.
//

import Foundation
import SwiftUI
import Flow


class WalletViewModel : ObservableObject {
    
    //TODO: 这里需要知道，没有钱包的时候怎么处理
    @Published var walletName: String = ""
    @Published var balance: String = ""
    @Published var address: String = ""
    
    private var walletService = WalletService()
    private var showAddress: Bool = true
    
    
    init() {
        Task{
            await refreshWallet()
        }
    }
    
    func refreshWallet() async {
        do {
            try await walletService.fetchWallet()
            updateInfo()
        }catch {
            print("获取钱包信息失败：\(error)")
        }
    }
    
    private func updateInfo() {
        DispatchQueue.main.async {
            self.walletName = self.walletService.walletName
            self.balance = "$ \(self.walletService.totalBalance)"
            self.address = self.walletService.address
            print("当前钱包: \(self.walletName) \n 余额：\(self.balance)")
        }
    }
    
}

extension WalletViewModel {
    func toggleAddress() {
        //TODO: 怎么处理，
        showAddress = !showAddress
        self.address = showAddress ? self.walletService.address : ""
    }
}

extension WalletViewModel {
    func copyAddress() {
        UIPasteboard.general.string = self.address
    }
}
