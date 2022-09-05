//
//  FCLScripts.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import Foundation

class FCLScripts {
    private static let PreAuthzReplacement = "$PRE_AUTHZ_REPLACEMENT"
    private static let AddressReplacement = "$ADDRESS_REPLACEMENT"
    private static let KeyIDReplacement = "$KEY_ID_REPLACEMENT"
    private static let PayerAddressReplacement = "$PAYER_ADDRESS_REPLACEMENT"
    private static let SignatureReplacement = "$SIGNATURE_REPLACEMENT"
    private static let UserSignatureReplacement = "$USER_SIGNATURE_REPLACEMENT"
    private static let AccountProofReplacement = "$ACCOUNT_PROOF_REPLACEMENT"
    private static let NonceReplacement = "$NONCE_REPLACEMENT"
    
    private static let preAuthzResponse = """
        {
            "status": "APPROVED",
            "data": {
                "f_type": "PreAuthzResponse",
                "f_vsn": "1.0.0",
                "proposer": {
                    "f_type": "Service",
                    "f_vsn": "1.0.0",
                    "type": "authz",
                    "uid": "lilico#authz",
                    "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                    "method": "EXT/RPC",
                    "identity": {
                        "address": "$ADDRESS_REPLACEMENT",
                        "keyId": 0
                    }
                },
                "payer": [
                    {
                        "f_type": "Service",
                        "f_vsn": "1.0.0",
                        "type": "authz",
                        "uid": "lilico#authz",
                        "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                        "method": "EXT/RPC",
                        "identity": {
                            "address": "$PAYER_ADDRESS_REPLACEMENT",
                            "keyId": 0
                        }
                    }
                ],
                "authorization": [
                    {
                        "f_type": "Service",
                        "f_vsn": "1.0.0",
                        "type": "authz",
                        "uid": "lilico#authz",
                        "endpoint": "chrome-extension://hpclkefagolihohboafpheddmmgdffjm/popup.html",
                        "method": "EXT/RPC",
                        "identity": {
                            "address": "$ADDRESS_REPLACEMENT",
                            "keyId": 0
                        }
                    }
                ]
            },
            "type": "FCL:VIEW:RESPONSE"
        }
    """
    
    private static let signMessageResponse = """
        {
          "f_type": "PollingResponse",
          "f_vsn": "1.0.0",
          "status": "APPROVED",
          "reason": null,
          "data": {
            "f_type": "CompositeSignature",
            "f_vsn": "1.0.0",
            "addr": "$ADDRESS_REPLACEMENT",
            "keyId": 0,
            "signature": "$SIGNATURE_REPLACEMENT"
          },
          "type": "FCL:VIEW:RESPONSE"
        }
    """
}

extension FCLScripts {
    static func generatePreAuthzResponse(address: String) -> String {
        let dict = [AddressReplacement: address, PayerAddressReplacement: RemoteConfigManager.shared.payer]
        return FCLScripts.preAuthzResponse.replace(by: dict)
    }
    
    static func generateSignMessageResponse(message: String, address: String) -> String? {
        let data = Data(hex: message)
        guard let signedData = WalletManager.shared.signSync(signableData: data) else {
            return nil
        }
        
        let hex = signedData.hexString
        let dict = [AddressReplacement: address, SignatureReplacement: hex]
        return FCLScripts.signMessageResponse.replace(by: dict)
    }
}
