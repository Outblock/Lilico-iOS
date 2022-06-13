//
//  AddAddressViewModel.swift
//  Lilico
//
//  Created by Selina on 1/6/2022.
//

import Foundation

extension AddAddressView {
    enum AddressStateType {
        case idle
        case checking
        case passed
        case invalidFormat
        case notFound
        
        var desc: String {
            switch self {
            case .invalidFormat:
                return "invalid_address".localized
            case .notFound:
                return "can_not_find_address".localized
            default:
                return ""
            }
        }
    }
    
    struct AddAddressState {
        var name: String = "" {
            didSet {
                refreshReadyFlag()
            }
        }
        
        var address: String = ""
        
        var addressStateType: AddressStateType = .idle {
            didSet {
                refreshReadyFlag()
            }
        }
        
        var isReadyForSave = false
        var needShowLoadingHud = false
        
        var isEditingMode = false
        var editingContact: Contact?
        
        private mutating func refreshReadyFlag() {
            let finalName = name.trim()
            let finalAddress = address.trim().lowercased()
            
            if finalName.isEmpty {
                isReadyForSave = false
                return
            }
            
            if addressStateType != .passed {
                isReadyForSave = false
                return
            }
            
            if isEditingMode {
                if finalName == editingContact?.contactName, finalAddress == editingContact?.address {
                    isReadyForSave = false
                    return
                }
            }
            
            isReadyForSave = true
        }
    }
    
    enum AddAddressInput {
        case checkAddress
        case save
    }
    
    class AddAddressViewModel: ViewModel {
        @Published var state: AddAddressState
        @RouterObject var router: AddressBookCoordinator.Router?
        
        private var addressCheckTask: DispatchWorkItem?
        
        init() {
            state = AddAddressState()
        }
        
        init(contact: Contact) {
            state = AddAddressState()
            state.isEditingMode = true
            state.editingContact = contact
            state.name = contact.contactName ?? ""
            state.address = contact.address ?? ""
            
            trigger(.checkAddress)
        }
        
        func trigger(_ input: AddAddressInput) {
            switch input {
            case .checkAddress:
                checkAddressAction()
            case .save:
                saveAction()
            }
        }
        
        private func saveAction() {
            if checkContactExists() == true {
                HUD.error(title: "contact_exists".localized)
                return
            }
            
            if state.isEditingMode {
                editContactAction()
                return
            }
            
            addContactAction()
        }
        
        private func addContactAction() {
            state.needShowLoadingHud = true
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()
            
            let errorAction = {
                DispatchQueue.main.async {
                    self.state.needShowLoadingHud = false
                    HUD.error(title: "request_failed".localized)
                }
            }
            
            let successAction = {
                DispatchQueue.main.async {
                    self.state.needShowLoadingHud = false
                    self.router?.coordinator.addressBookVM?.trigger(.load)
                    self.router?.pop()
                    HUD.success(title: "contact_added".localized)
                }
            }
            
            Task {
                do {
                    let request = AddressBookAddRequest(contactName: contactName, address: address, domain: "", domainType: .unknown, username: "")
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.AddressBook.addExternal(request))
                    
                    if response.httpCode != 200 {
                        errorAction()
                        return
                    }
                    
                    successAction()
                } catch {
                    errorAction()
                }
            }
        }
        
        private func editContactAction() {
            state.needShowLoadingHud = true
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()
            
            let errorAction = {
                DispatchQueue.main.async {
                    self.state.needShowLoadingHud = false
                    HUD.error(title: "request_failed".localized)
                }
            }
            
            let successAction = {
                DispatchQueue.main.async {
                    self.state.needShowLoadingHud = false
                    self.router?.coordinator.addressBookVM?.trigger(.load)
                    self.router?.pop()
                    HUD.success(title: "contact_edited".localized)
                }
            }
            
            Task {
                do {
                    guard let id = state.editingContact?.id, let domainType = state.editingContact?.domain?.domainType else {
                        errorAction()
                        return
                    }
                    
                    let request = AddressBookEditRequest(id: id, contactName: contactName, address: address, domain: "", domainType: domainType, username: "")
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.AddressBook.edit(request))
                    
                    if response.httpCode != 200 {
                        errorAction()
                        return
                    }
                    
                    successAction()
                } catch {
                    errorAction()
                }
            }
        }
        
        private func checkContactExists() -> Bool {
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()
            let domain = Contact.Domain(domainType: .unknown, value: "")
            let contact = Contact(address: address, avatar: nil, contactName: contactName, contactType: .external, domain: domain, id: 0, username: "")
            
            return router?.coordinator.addressBookVM?.contactIsExists(contact) ?? false
        }
        
        private func checkAddressAction() {
            cancelCurrentAddressCheckTask()
            
            if state.address.isEmpty {
                state.addressStateType = .idle
                return
            }
            
            var formatedAddress = state.address.trim().lowercased()
            if !formatedAddress.hasPrefix("0x") {
                formatedAddress = "0x" + formatedAddress
            }
            
            if !checkAddressFormat(formatedAddress) {
                state.addressStateType = .invalidFormat
                return
            } else {
                state.addressStateType = .idle
            }
            
            delayCheckAddressIsExist(formatedAddress)
        }
    }
}

extension AddAddressView.AddAddressViewModel {
    private func checkAddressFormat(_ address: String) -> Bool {
        return address.matchRegex("^0x[a-fA-F0-9]{16}$")
    }
    
    private func delayCheckAddressIsExist(_ address: String) {
        let task = DispatchWorkItem {
            self.state.addressStateType = .checking
            
            FlowNetwork.addressVerify(address: address) { exist, error in
                DispatchQueue.main.async {
                    self.state.addressStateType = exist ? .passed : .notFound
                }
            }
        }
        addressCheckTask = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }
    
    private func cancelCurrentAddressCheckTask() {
        if let task = addressCheckTask {
            task.cancel()
            addressCheckTask = nil
        }
    }
}