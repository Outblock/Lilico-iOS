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
    }
    
    enum AddressBookInput {
        case load
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
