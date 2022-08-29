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
        if token.isActivated {
            return
        }
        
        pendingActiveToken = token
        withAnimation(.easeInOut(duration: 0.2)) {
            confirmSheetIsPresented = true
        }
    }
    
    func confirmActiveTokenAction(_ token: TokenModel) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.dismissLoading()
                HUD.error(title: "add_token_failed".localized)
            }
        }
        
        isRequesting = true
        HUD.loading("loading".localized)
        
        Task {
            do {
                let transactionId = try await FlowNetwork.enableToken(at: Flow.Address(hex: address), token: token)
                
                guard let data = try? JSONEncoder().encode(token) else {
                    failedBlock()
                    return
                }
                
                self.isRequesting = false
                self.confirmSheetIsPresented = false
                HUD.dismissLoading()
                
                let holder = TransactionManager.TransactionHolder(id: transactionId, type: .addToken, data: data)
                TransactionManager.shared.newTransaction(holder: holder)
            } catch {
                debugPrint("AddTokenViewModel -> confirmActiveTokenAction error: \(error)")
                failedBlock()
            }
        }
    }
}
