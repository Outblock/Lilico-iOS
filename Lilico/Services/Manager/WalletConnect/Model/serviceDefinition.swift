//
//  ServiceDef.swift
//  Lilico
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation


func serviceDefinition(address: String, keyId: Int, type: FCLServiceType) -> Service {
    
    var service = Service(fType: "Service",
                          fVsn: "1.0.0",
                          type: type,
                          method: .none,
                          endpoint: nil,
                          uid: "https://link.lilico.app/wc",
                          id: nil,
                          identity: nil,
                          provider: nil, params: nil)
    
    if type == .authn {
        service.id = address
        service.identity = Identity(address: address, keyId: keyId)
        service.provider = Provider(fType: "ServiceProvider", fVsn: "1.0.0", address: address, name: "Flow Wallet")
        service.endpoint = "flow_authn"
    }
    
    if type == .authz {
        service.method = .walletConnect
        service.identity = Identity(address: address, keyId: keyId)
        service.endpoint = "flow_authz"
    }
    
    if type == .userSignature {
        service.method = .walletConnect
        service.identity = Identity(address: address, keyId: keyId)
        service.endpoint = "flow_user_sign"
    }
    
    return service
}
