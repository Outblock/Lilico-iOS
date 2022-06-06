//
//  AddressBookViewModel.swift
//  Lilico
//
//  Created by Selina on 24/5/2022.
//

import SwiftUI

// MARK: - Define

extension AddressBookView {
    struct SectionState: Identifiable {
        var sectionName: String
        var list: [Contact]
        
        var id: String {
            return sectionName
        }
    }
    
    class SectionViewModel: ViewModel, Identifiable, Indexable {
        @Published var state: SectionState
        
        var id: String {
            return state.id
        }
        
        var index: Index? {
            return Index(state.sectionName, contentID: state.id)
        }
        
        init(sectionName: String, list: [Contact]) {
            state = SectionState(sectionName: sectionName, list: list)
        }
        
        func trigger(_ input: Never) {
            
        }
    }
}

extension AddressBookView {
    enum AddressBookViewStateType {
        case idle
        case loading
        case error
    }
    
    struct ListState {
        var sections: [SectionViewModel]
        var stateType: AddressBookViewStateType = .loading
        var hudStatus: Bool = false
    }
    
    enum AddressBookInput {
        case load
        case delete(SectionViewModel, Contact)
    }
}

// MARK: - Implementation

extension AddressBookView {
    class AddressBookViewModel: ViewModel {
        @Published var state: ListState
        @Published var searchText: String = ""
        
        init() {
            state = ListState(sections: [SectionViewModel]())
            trigger(.load)
        }
        
        func trigger(_ input: AddressBookInput) {
            switch input {
            case .load:
                load()
            case .delete(let sectionVM, let contact):
                delete(sectionVM: sectionVM, contact: contact)
            }
        }
        
        private func trimListModels() {
            state.sections = state.sections.filter { svm in
                svm.state.list.isEmpty == false
            }
        }
        
        private func delete(sectionVM: SectionViewModel, contact: Contact) {
            guard let index = sectionVM.state.list.firstIndex(where: { c in
                c.id == contact.id
            }) else {
                return
            }
            
            state.hudStatus = true
            
            let successAction = {
                DispatchQueue.main.async {
                    self.state.hudStatus = false
                    sectionVM.state.list.remove(at: index)
                    self.trimListModels()
                    HUD.success(title: "Contact deleted")
                }
            }
            
            let failedAction = {
                DispatchQueue.main.async {
                    self.state.hudStatus = false
                    HUD.error(title: "Delete failed")
                }
            }
            
            Task {
                do {
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.AddressBook.delete(contact.id))
                    
                    if response.httpCode != 200 {
                        failedAction()
                        return
                    }
                    
                    successAction()
                } catch {
                    failedAction()
                }
            }
        }
        
        private func load() {
            state.stateType = .loading
            
            Task {
                do {
                    let response: AddressListBookResponse = try await Network.request(LilicoAPI.AddressBook.fetchList)
                    DispatchQueue.main.async {
                        self.regroup(response.contacts)
                        self.state.stateType = .idle
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.state.stateType = .error
                    }
                }
            }
        }
        
        private func regroup(_ contacts: [Contact]?) {
            var rawContacts = contacts
            if rawContacts == nil {
                rawContacts = []
            }
            
            BMChineseSort.share.compareTpye = .fullPinyin
            BMChineseSort.sortAndGroup(objectArray: rawContacts, key: "contactName") { success, unGroupedArr, sectionTitleArr, sortedObjArr in
                if !success {
                    self.state.stateType = .error
                    return
                }
                
                var sections = [SectionViewModel]()
                for (index, title) in sectionTitleArr.enumerated() {
                    let svm = SectionViewModel(sectionName: title, list: sortedObjArr[index])
                    sections.append(svm)
                }
                
                self.state.sections = sections
            }
        }
    }
}

// MARK: - Search

extension AddressBookView.AddressBookViewModel {
    var searchResults: [AddressBookView.SectionViewModel] {
        if searchText.isEmpty {
            return state.sections
        }
        
        var searchSections: [AddressBookView.SectionViewModel] = []
        
        for section in state.sections {
            var contacts = [Contact]()
            
            for contact in section.state.list {
                if let address = contact.address, address.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }

                if let contactName = contact.contactName, contactName.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }

                if let userName = contact.username, userName.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }
            }
            
            if contacts.count > 0 {
                let newSection = AddressBookView.SectionViewModel(sectionName: section.state.sectionName, list: contacts)
                searchSections.append(newSection)
            }
        }
        
        return searchSections
    }
}
