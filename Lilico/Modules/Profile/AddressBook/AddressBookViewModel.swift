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
        
        init() {
            let contacts = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel")
            ]
            
            let contacts2 = [
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 0, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 1, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 2, username: "angel"),
                Contact(address: "0x55ad22f01ef568a1", avatar: nil, contactName: "Angel", contactType: nil, domain: nil, id: 3, username: "angel")
            ]
            
            let sections = [
                SectionViewModel(sectionName: "A", list: contacts),
                SectionViewModel(sectionName: "B", list: contacts2)
            ]
            
            state = ListState(sections: sections)
        }
        
        func trigger(_ input: Never) {
            
        }
    }
}

extension AddressBookView {
    struct SectionState: Identifiable {
        var sectionName: String
        var list: [Contact]
        
        var id: String {
            sectionName
        }
    }
    
    class SectionViewModel: ViewModel {
        @Published var state: SectionState
        
        init(sectionName: String, list: [Contact]) {
            state = SectionState(sectionName: sectionName, list: list)
        }
        
        func trigger(_ input: Never) {
            
        }
    }
}
