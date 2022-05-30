//
//  RecoveryPhraseViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import SPIndicator

class RecoveryPhraseViewModel: ViewModel {
    @Published
    private(set) var state: RecoveryPhraseView.ViewState

    let mockData = [
        WordListView.WordItem(id: 1, word: "---"),
        WordListView.WordItem(id: 2, word: "---"),
        WordListView.WordItem(id: 3, word: "---"),
        WordListView.WordItem(id: 4, word: "---"),
        WordListView.WordItem(id: 5, word: "---"),
        WordListView.WordItem(id: 6, word: "---"),
        WordListView.WordItem(id: 7, word: "---"),
        WordListView.WordItem(id: 8, word: "---"),
        WordListView.WordItem(id: 9, word: "---"),
        WordListView.WordItem(id: 10, word: "---"),
        WordListView.WordItem(id: 11, word: "---"),
        WordListView.WordItem(id: 12, word: "---"),
    ]

    @RouterObject
    var homeRouter: WalletCoordinator.Router?

    @RouterObject
    var router: BackupCoordinator.Router?

    init() {
        if let mnemonic = WalletManager.shared.getMnemoic() {
            state = RecoveryPhraseView.ViewState(dataSource: mnemonic.split(separator: " ").enumerated().map { item in
                WordListView.WordItem(id: item.offset + 1, word: String(item.element))
            })
        } else {
            state = RecoveryPhraseView.ViewState(dataSource: mockData)
        }
    }

    func trigger(_ input: RecoveryPhraseView.Action) {
        switch input {
        case .icloudBackup:
//            Task {
//                await MainActor.run {
//                    state.icloudLoading = true
//                }
//                do {
//                    try BackupManager.shared.setAccountDatatoiCloud()
//
//                    await MainActor.run {
//                        state.icloudLoading = false
//                        HUD.present(title: "Backup Success")
//                    }
//
//                } catch {
//                    await MainActor.run {
//                        state.icloudLoading = false
//                        HUD.error(title: "Backup Failed")
//                    }
//                }
//            }
            router?.route(to: \.backupPassword)
        case .googleBackup:
            router?.route(to: \.createPin)
        case .manualBackup:
            router?.route(to: \.manualBackup)
        case .back:
            homeRouter?.popToRoot()
        }
    }
}
