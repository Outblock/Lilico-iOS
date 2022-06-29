//
//  AddTokenViewModel.swift
//  Lilico
//
//  Created by Selina on 27/6/2022.
//

import SwiftUI
import Combine
import Flow

extension AddTokenViewModel {
    class Section: ObservableObject, Identifiable, Indexable {
        @Published var sectionName: String = "#"
        @Published var tokenList: [TokenModel] = []
        
        var id: String {
            return sectionName
        }
        
        var index: Index? {
            return Index(sectionName, contentID: id)
        }
    }
}

class AddTokenViewModel: ObservableObject {
    @Published var sections: [Section] = []
    @Published var searchText: String = ""
    
    @Published var confirmSheetIsPresented = false
    var pendingActiveToken: TokenModel?
    
    @Published var isRequesting: Bool = false
    
    private var cancelSets = Set<AnyCancellable>()
    private var checkTask: DispatchWorkItem?
    private var loopCheckTimes: Int = 0
    
    init() {
        WalletManager.shared.$activatedCoins.sink { _ in
            DispatchQueue.main.async {
                self.reloadData()
            }
        }.store(in: &cancelSets)
    }
    
    private func reloadData() {
        guard let supportedTokenList = WalletManager.shared.supportedCoins else {
            sections = []
            return
        }
        
        regroup(supportedTokenList)
    }
    
    private func regroup(_ tokens: [TokenModel]) {
        BMChineseSort.share.compareTpye = .fullPinyin
        BMChineseSort.sortAndGroup(objectArray: tokens, key: "name") { success, _, sectionTitleArr, sortedObjArr in
            if !success {
                assert(false, "can not be here")
                return
            }

            var sections = [AddTokenViewModel.Section]()
            for (index, title) in sectionTitleArr.enumerated() {
                let section = AddTokenViewModel.Section()
                section.sectionName = title
                section.tokenList = sortedObjArr[index]
                sections.append(section)
            }

            DispatchQueue.main.async {
                self.sections = sections
            }
        }
    }
}

extension AddTokenViewModel {
    var searchResults: [AddTokenViewModel.Section] {
        if searchText.isEmpty {
            return self.sections
        }

        var searchSections: [AddTokenViewModel.Section] = []

        for section in self.sections {
            var list = [TokenModel]()

            for token in section.tokenList {
                if token.name.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }

                if token.contractName.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }

                if let symbol = token.symbol, symbol.localizedCaseInsensitiveContains(searchText) {
                    list.append(token)
                    continue
                }
            }

            if list.count > 0 {
                let newSection = AddTokenViewModel.Section()
                newSection.sectionName = section.sectionName
                newSection.tokenList = list
                searchSections.append(newSection)
            }
        }

        return searchSections

    }
}

// MARK: - Action

extension AddTokenViewModel {
    func willActiveTokenAction(_ token: TokenModel) {
        pendingActiveToken = token
        withAnimation(.easeInOut(duration: 0.2)) {
            confirmSheetIsPresented = true
        }
    }
    
    func confirmActiveTokenAction(_ token: TokenModel) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        isRequesting = true
        Task {
            do {
                let transactionId = try await FlowNetwork.enableToken(at: Flow.Address(hex: address), token: token)
                loopCheckTimes = 0
                loopCheckTransactionResult(id: transactionId.hex)
            } catch {
                debugPrint("AddTokenViewModel -> confirmActiveTokenAction error: \(error)")
                
                DispatchQueue.main.async {
                    self.isRequesting = false
                    HUD.error(title: "add_token_failed".localized)
                }
            }
        }
    }
}

extension AddTokenViewModel {
    private func loopCheckTransactionResult(id: String) {
        if loopCheckTimes >= 20 {
            debugPrint("AddTokenViewModel -> loopCheckTransactionResult timeout")
            
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "add_token_timeout".localized)
            }
            return
        }
        
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            Task {
                do {
                    let result = try await FlowNetwork.getTransactionResult(by: id)
                    if result.isProcessing {
                        debugPrint("AddTokenViewModel -> loopCheckTransactionResult isProcessing")
                        self.loopCheckTransactionResult(id: id)
                        return
                    }
                    
                    if result.isFailed {
                        debugPrint("AddTokenViewModel -> loopCheckTransactionResult failed")
                        
                        DispatchQueue.main.async {
                            self.isRequesting = false
                            HUD.error(title: "add_token_failed".localized)
                        }
                        return
                    }
                    
                    if result.isComplete {
                        debugPrint("AddTokenViewModel -> loopCheckTransactionResult isComplete")
                        
                        DispatchQueue.main.async {
                            self.isRequesting = false
                            self.confirmSheetIsPresented = false
                            HUD.success(title: "add_token_success".localized)
                        }
                        return
                    }
                } catch {
                    debugPrint("AddTokenViewModel -> loopCheckTransactionResult failed: \(error)")
                    self.loopCheckTransactionResult(id: id)
                }
            }
        }
        
        checkTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
        loopCheckTimes += 1
    }
}
