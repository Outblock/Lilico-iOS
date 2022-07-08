//
//  WalletSendViewModel.swift
//  Lilico
//
//  Created by Selina on 8/7/2022.
//

import Foundation
import SwiftUI
import SwiftUIPager
import Flow

extension WalletSendView {
    enum TabType: Int, CaseIterable {
        case recent
        case addressBook
    }
    
    enum ViewStatus {
        case normal
        case prepareSearching
        case searching
        case searchResult
        case error
    }
    
    enum ErrorType {
        case none
        case notFound
        case failed
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .notFound:
                return "no_account_found_msg".localized
            case .failed:
                return "search_failed_msg".localized
            }
        }
    }
    
    struct SearchSection: VSectionListSectionViewModelable {
        let id: UUID = .init()
        let title: String
        let rows: [Contact]
    }
}

class WalletSendViewModel: ObservableObject {
    @Published var status: WalletSendView.ViewStatus = .normal
    @Published var errorType: WalletSendView.ErrorType = .none
    
    @Published var tabType: WalletSendView.TabType = .recent
    @Published var searchText: String = ""
    @Published var page: Page = .first()
    
    // TODO: recentList implementation
    @Published var recentList: [Contact] = []
    let addressBookVM = AddressBookView.AddressBookViewModel()
    
    @Published var localSearchResults: [WalletSendView.SearchSection] = []
    @Published var serverSearchList: [Contact]?
    @Published var findSearchList: [Contact]?
    @Published var flownsSearchList: [Contact]?
    
    var remoteSearchResults: [WalletSendView.SearchSection] {
        var sections = [WalletSendView.SearchSection]()
        if let serverSearchList = serverSearchList, !serverSearchList.isEmpty {
            sections.append(WalletSendView.SearchSection(title: "lilico_user".localized, rows: serverSearchList))
        }
        
        if let findSearchList = findSearchList, !findSearchList.isEmpty {
            sections.append(WalletSendView.SearchSection(title: ".find".localized, rows: findSearchList))
        }
        
        if let flownsSearchList = flownsSearchList, !flownsSearchList.isEmpty {
            sections.append(WalletSendView.SearchSection(title: ".flowns".localized, rows: flownsSearchList))
        }
        
        return sections
    }
}

// MARK: - Search

extension WalletSendViewModel {
    private func searchLocal() {
        let text = searchText.trim()
        localSearchResults = addressBookVM.searchLocal(text: text)
    }
    
    private func searchRemote() {
        searchFromServer()
        searchFromFind()
        searchFromFlowns()
    }
    
    private func searchFromServer() {
        let trimedText = searchText.trim()
        
        Task {
            do {
                let response: UserSearchResponse = try await Network.request(LilicoAPI.User.search(trimedText))
                if trimedText != self.searchText.trim() {
                    return
                }
                
                DispatchQueue.main.async {
                    var results = [Contact]()
                    let users = response.users ?? []
                    for userInfo in users {
                        results.append(userInfo.toContact())
                    }
                    
                    self.serverSearchList = results
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            } catch {
                debugPrint("WalletSendViewModel -> searchFromServer failed: \(error)")
                
                if trimedText != self.searchText.trim() {
                    return
                }
                
                HUD.error(title: "search_failed_msg".localized)
                
                DispatchQueue.main.async {
                    self.serverSearchList = []
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            }
        }
    }
    
    private func searchFromFind() {
        let trimedText = searchText.trim()
        
        Task {
            do {
                let address = try await FlowNetwork.queryAddressByDomainFind(domain: trimedText.lowercased().removeSuffix(".find"))
                if trimedText != self.searchText.trim() {
                    return
                }
                
                DispatchQueue.main.async {
                    let contact = Contact(address: address,
                                          avatar: nil,
                                          contactName: trimedText,
                                          contactType: .domain,
                                          domain: Contact.Domain(domainType: .find, value: trimedText),
                                          id: UUID().hashValue,
                                          username: nil)
                    
                    self.findSearchList = [contact]
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            } catch {
                debugPrint("WalletSendViewModel -> searchFromFind failed: \(error)")
                
                if trimedText != self.searchText.trim() {
                    return
                }
                
                DispatchQueue.main.async {
                    self.findSearchList = []
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            }
        }
    }
    
    private func searchFromFlowns() {
        let trimedText = searchText.trim()
        
        Task {
            do {
                let address = try await FlowNetwork.queryAddressByDomainFlowns(domain: trimedText)
                if trimedText != self.searchText.trim() {
                    return
                }
                
                DispatchQueue.main.async {
                    let contact = Contact(address: address,
                                          avatar: nil,
                                          contactName: trimedText,
                                          contactType: .domain,
                                          domain: Contact.Domain(domainType: .flowns, value: trimedText.removeSuffix(".find")),
                                          id: UUID().hashValue,
                                          username: nil)
                    
                    self.flownsSearchList = [contact]
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            } catch {
                debugPrint("WalletSendViewModel -> searchFlowns failed: \(error)")
                
                if trimedText != self.searchText.trim() {
                    return
                }
                
                DispatchQueue.main.async {
                    self.flownsSearchList = []
                    self.refreshCurrentSearchingStatusAfterPerSearchComplete()
                }
            }
        }
    }
    
    private func clearRemoteSearch() {
        serverSearchList = nil
        findSearchList = nil
        flownsSearchList = nil
    }
    
    /// refresh searching status by search result
    private func refreshCurrentSearchingStatusAfterPerSearchComplete() {
        if let serverSearchList = serverSearchList, serverSearchList.isEmpty,
           let findSearchList = findSearchList, findSearchList.isEmpty,
           let flownsSearchList = flownsSearchList, flownsSearchList.isEmpty {
            errorType = .notFound
            status = .error
            return
        }
        
        status = .searchResult
    }
}

// MARK: - Action

extension WalletSendViewModel {
    func searchTextDidChangeAction(text: String) {
        let trimedText = text.trim()
        
        if trimedText.isEmpty {
            status = .normal
            return
        }
        
        if needAutoSearch(text: trimedText) {
            searchCommitAction()
            return
        }
        
        status = .prepareSearching
        clearRemoteSearch()
        searchLocal()
    }
    
    func searchCommitAction() {
        status = .searching
        clearRemoteSearch()
        searchRemote()
    }
    
    func changeTabTypeAction(type: WalletSendView.TabType) {
        withAnimation(.easeInOut(duration: 0.2)) {
            tabType = type
            page.update(.new(index: type.rawValue))
        }
    }
}

// MARK: - Helper

extension WalletSendViewModel {
    private func needAutoSearch(text: String) -> Bool {
        let trimedText = text.trim()
        
        if trimedText.contains(" ") {
            return false
        }
        
        return trimedText.hasSuffix(".find") || trimedText.hasSuffix(".fn")
    }
}
