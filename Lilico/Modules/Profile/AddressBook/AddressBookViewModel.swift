//
//  AddressBookViewModel.swift
//  Lilico
//
//  Created by Selina on 24/5/2022.
//

import SwiftUI

extension AddressBookView {
    struct ListState {
        var sections: [SectionViewModel]
    }
    
    class AddressBookViewModel: ViewModel {
        @Published var state: ListState
        @Published var searchText: String = ""
        
        init() {
            let contacts = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 4, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 5, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 6, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 7, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 8, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 9, username: "angel"),
            ]
            
            let contacts2 = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 4, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 5, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 6, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 7, username: "angel"),
            ]
            
            let contacts3 = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 4, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 5, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 6, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 7, username: "angel"),
            ]
            
            let contacts4 = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 4, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 5, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 6, username: "angel"),
                Contact(address: "0x55ad22f01ef59999", avatar: nil, contactName: "Lilin", contactType: nil, domain: nil, id: 7, username: "angel"),
            ]
            
            let contacts5 = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 4, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "李刚", contactType: nil, domain: nil, id: 5, username: "angel"),
                Contact(address: "0x55ad22f01ef58888", avatar: nil, contactName: "Luka", contactType: nil, domain: nil, id: 6, username: "angel"),
                Contact(address: "0x55ad22f01ef56888", avatar: nil, contactName: "Jack", contactType: nil, domain: nil, id: 7, username: "angel"),
            ]
            
            let sections = [
                SectionViewModel(sectionName: "A", list: contacts),
                SectionViewModel(sectionName: "B", list: contacts2),
                SectionViewModel(sectionName: "C", list: contacts3),
                SectionViewModel(sectionName: "E", list: contacts4),
                SectionViewModel(sectionName: "F", list: contacts5),
            ]
            
            state = ListState(sections: sections)
        }
        
        func trigger(_ input: Never) {
            
        }
        
        var searchResults: [SectionViewModel] {
            if searchText.isEmpty {
                return state.sections
            }
            
            var searchSections: [SectionViewModel] = []
            
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
                    let newSection = SectionViewModel(sectionName: section.state.sectionName, list: contacts)
                    searchSections.append(newSection)
                }
            }
            
            return searchSections
        }
    }
}

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
