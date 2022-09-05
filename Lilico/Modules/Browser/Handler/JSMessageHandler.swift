//
//  JSMessageHandler.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit

enum JSMessageType: String {
    case ready = "FCL:VIEW:READY"
    case response = "FCL:VIEW:READY:RESPONSE"
}

class JSMessageHandler {
    private var processingMessage: String?
    private var processingServiceType: FCLServiceType?
    private var processingFCLResponse: FCLResponseProtocol?
    private var readyToSignEnvelope: Bool = false
    
    weak var webVC: BrowserViewController?
}

extension JSMessageHandler {
    func handleMessage(_ message: String) {
        if message.isEmpty || processingMessage == message {
            return
        }
        
        if WalletManager.shared.getPrimaryWalletAddress() == nil {
            HUD.error(title: "browser_not_login".localized)
            return
        }
        
        processingMessage = message
        debugPrint("JSMessageHandler -> handleMessage: \(message)")
        
        do {
            if let msgData = message.data(using: .utf8),
               let jsonDict = try JSONSerialization.jsonObject(with: msgData, options: .mutableContainers) as? [String: AnyObject] {
                if messageIsServce(jsonDict) {
                    handleService(message)
                } else if jsonDict["type"] as? String == JSMessageType.response.rawValue {
                    handleReadyResponse(message)
                }
            } else {
                debugPrint("JSMessageHandler -> handleMessage: decode message failed: \(message)")
            }
        } catch {
            debugPrint("JSMessageHandler -> handleMessage: invalid message: \(message)")
        }
    }
    
    private func messageIsServce(_ dict: [String: AnyObject]) -> Bool {
        guard dict["type"] == nil else {
            return false
        }
        
        guard let serviceDict = dict["service"] as? [String: AnyObject] else {
            return false
        }
        
        if serviceDict["type"] != nil || serviceDict["f_type"] as? String == "Service" {
            return true
        }
        
        return false
    }
}

// MARK: - Service

extension JSMessageHandler {
    private func handleService(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleService: decode message failed: \(message)")
                return
                
            }
            
            let serviceWrapper = try JSONDecoder().decode(JSFCLServiceModelWrapper.self, from: data)
            processingServiceType = serviceWrapper.service.type
            
            if processingServiceType == .preAuthz {
                webVC?.postPreAuthzResponse()
            } else {
                webVC?.postReadyResponse()
            }
        } catch {
            debugPrint("JSMessageHandler -> handleService: decode message failed: \(message)")
        }
    }
}

// MARK: - Response

extension JSMessageHandler {
    private func handleReadyResponse(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleReadyResponse: decode message failed: \(message)")
                return
            }
            
            let fcl = try JSONDecoder().decode(FCLSimpleResponse.self, from: data)
            
            if self.processingServiceType != fcl.serviceType {
                debugPrint("JSMessageHandler -> handleReadyResponse: service not same (old: \(String(describing: self.processingServiceType)), new: \(fcl.serviceType))")
                return
            }
            
            switch fcl.serviceType {
            case .authn:
                handleAuthn(message)
            case .authz:
                handleAuthz(message)
            case .userSignature:
                handleUserSignature(message)
            default:
                debugPrint("JSMessageHandler -> handleReadyResponse: unsupport service type: \(fcl.serviceType)")
            }
        } catch {
            debugPrint("JSMessageHandler -> handleReadyResponse: decode message failed: \(message)")
        }
    }
    
    private func handleAuthn(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleAuthn: decode message failed: \(message)")
                return
            }
            
            let authnResponse = try JSONDecoder().decode(FCLAuthnResponse.self, from: data)
            
            if authnResponse.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleAuthn, is processing: \(authnResponse.uniqueId())")
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthn")
            processingFCLResponse = authnResponse
            
            // TODO: show authn dialog
        } catch {
            debugPrint("JSMessageHandler -> handleAuthn: decode message failed: \(message)")
        }
    }
    
    private func handleAuthz(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleAuthz: decode message failed: \(message)")
                return
            }
            
            let authzResponse = try JSONDecoder().decode(FCLAuthzResponse.self, from: data)
            
            if authzResponse.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleAuthz, is processing: \(authzResponse.uniqueId())")
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthz")
            processingFCLResponse = authzResponse
            
            if authzResponse.body.f_type == "Signable" {
                debugPrint("JSMessageHandler -> handleAuthz, roles: \(authzResponse.body.roles.value)")
            }
            
            if authzResponse.isSignAuthz {
                debugPrint("JSMessageHandler -> signAuthz")
                signAuthz(authzResponse)
                return
            }
            
            if authzResponse.isSignPayload {
                debugPrint("JSMessageHandler -> signPayload")
                signPayload(authzResponse)
                return
            }
            
            if readyToSignEnvelope && authzResponse.isSignEnvelope {
                debugPrint("JSMessageHandler -> signEnvelope")
                signEnvelope(authzResponse)
                return
            }
            
            debugPrint("JSMessageHandler -> handleAuthz: unknown authz: \(message)")
        } catch {
            debugPrint("JSMessageHandler -> handleAuthz: decode message failed: \(message)")
        }
    }
    
    private func handleUserSignature(_ message: String) {
        do {
            guard let data = message.data(using: .utf8) else {
                debugPrint("JSMessageHandler -> handleUserSignature: decode message failed: \(message)")
                return
            }
            
            let response = try JSONDecoder().decode(FCLSignMessageResponse.self, from: data)
            
            if response.uniqueId() == processingFCLResponse?.uniqueId() {
                debugPrint("JSMessageHandler -> handleUserSignature, is processing: \(response.uniqueId())")
                return
            }
            
            processingFCLResponse = response
            debugPrint("JSMessageHandler -> handleUserSignature, uid: \(response.uniqueId())")
            
            // TODO: show sign dialog
        } catch {
            debugPrint("JSMessageHandler -> handleUserSignature: decode message failed: \(message)")
        }
    }
}

extension JSMessageHandler {
    private func signAuthz(_ authzResponse: FCLAuthzResponse) {
        // TODO: show authz dialog
    }
    
    private func signPayload(_ authzResponse: FCLAuthzResponse) {
        
    }
    
    private func signEnvelope(_ authzResponse: FCLAuthzResponse) {
        
    }
}
