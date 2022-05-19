//
//  ManualBackupViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 4/1/22.
//

import Foundation
import WalletCore

class ManualBackupViewModel: ViewModel {
    @Published
    private(set) var state: ManualBackupView.ViewState = .initScreen

    @RouterObject
    var router: HomeCoordinator.Router?

    func loadScreen() {
//        state = .init(
//            dataSource: [
//                .init(position: 2, correct: 1, list: ["Abstract", "Apple", "Alience"]),
//                .init(position: 4, correct: 0, list: ["Food", "First", "Fire"]),
//                .init(position: 8, correct: 2, list: ["Loop", "Lilico", "Libra"]),
//                .init(position: 10, correct: 0, list: ["Zip", "Zion", "Zoo"])
//            ]
//        )

        guard let wallet = WalletManager.shared.wallet else {
            HUD.error(title: "Load wallet Error")
            return
        }

        let wordList = wallet.mnemonic.split(separator: " ")

        guard wordList.count == 12 else {
            HUD.error(title: "Inocrrect world length")
            return
        }

        let positions = [Int.random(in: 0 ... 2),
                         Int.random(in: 3 ... 5),
                         Int.random(in: 6 ... 8),
                         Int.random(in: 9 ... 11)]

        var dataSource: [ManualBackupView.BackupModel] = []
        for position in positions {
            let word = String(wordList[position])
            let matches = Mnemonic.search(prefix: String(word.prefix(1)))
            var matchList = matches.filter { $0 != word }.shuffled()[0 ... 1]
            matchList.append(word)
            matchList.shuffle()
            let firstIndex = matchList.firstIndex(of: word)
            dataSource.append(.init(position: position + 1,
                                    correct: firstIndex ?? 0,
                                    list: Array(matchList))
            )
        }

        DispatchQueue.main.async {
            self.state = .render(dataSource: dataSource)
        }
    }

    func trigger(_ input: ManualBackupView.Action) {
        switch input {
        case .backupSuccess:
//            router?.dismissCoordinator()
            router?.popToRoot()
        case .loadDataSource:
            loadScreen()
        }
    }
}
