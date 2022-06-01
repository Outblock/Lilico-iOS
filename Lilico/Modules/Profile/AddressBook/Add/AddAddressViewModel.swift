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
                return "Invalid address"
            case .notFound:
                return "Can't find address in chain"
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
        
        var isReadyForSave: Bool = false
        
        private mutating func refreshReadyFlag() {
            if name.trim().isEmpty {
                isReadyForSave = false
                return
            }
            
            if addressStateType != .passed {
                isReadyForSave = false
                return
            }
            
            isReadyForSave = true
        }
    }
    
    enum AddAddressInput {
        case checkAddress
    }
    
    class AddAddressViewModel: ViewModel {
        @Published var state: AddAddressState
        
        private var addressCheckTask: DispatchWorkItem?
        
        init() {
            state = AddAddressState()
        }
        
        func trigger(_ input: AddAddressInput) {
            switch input {
            case .checkAddress:
                cancelCurrentAddressCheckTask()
                
                if state.address.isEmpty {
                    state.addressStateType = .idle
                    return
                }
                
                var formatedAddress = state.address.trim()
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
