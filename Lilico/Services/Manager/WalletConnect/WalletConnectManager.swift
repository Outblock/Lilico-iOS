//
//  WalletConnectManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import WalletConnectSign
import WalletConnectUtils
import WalletConnectRelay
import Flow
import Starscream
import Combine
import WalletCore

class WalletConnectManager: ObservableObject {
    static let shared = WalletConnectManager()
    
    @Published
    var activeSessions: [Session] = []
    
    @Published
    var activePairings: [Pairing] = []
    
    private var publishers = [AnyCancellable]()
    
    
    var currentProposal: Session.Proposal?
    var currentRequest: WalletConnectSign.Request?
    var currentSessionInfo: SessionInfo?
    var currentRequestInfo: RequestInfo?
    var currentMessageInfo: RequestMessageInfo?
    
    init() {
        let metadata = AppMetadata(
            name: "Lilico",
            description: "A crypto wallet on Flow built for Explorers, Collectors and Gamers",
            url: "https://link.lilico.app/wc",
            icons: ["https://lilico.app/logo.png"])
        Sign.configure(metadata: metadata, projectId: "29b38ec12be4bd19bf03d7ccef29aaa6", socketFactory: SocketFactory())
        reloadActiveSessions()
        reloadPairing()
        setUpAuthSubscribing()
    }
    
    func connect(link: String) {
        debugPrint("WalletConnectManager -> connect(), Thread: \(Thread.isMainThread)")
        print("[RESPONDER] Pairing to: \(link)")
        Task {
            do {
                try await Sign.instance.pair(uri: link)
            } catch {
                print("[PROPOSER] Pairing connect error: \(error)")
                HUD.error(title: "Connect failed")
            }
        }
    }
    
    
    func reloadActiveSessions() {
        let settledSessions = Sign.instance.getSessions()
        activeSessions = settledSessions
//        sessionItems = settledSessions.map { session -> ActiveSessionItem in
//            let app = session.peer
//            return ActiveSessionItem(
//                dappName: app.name,
//                dappURL: app.url,
//                iconURL: app.icons.first ?? "",
//                topic: session.topic)
//        }
    }
    
    func disconnect(topic: String) async {
        do {
            try await Sign.instance.disconnect(topic: topic)
            reloadActiveSessions()
        } catch {
            print(error)
            HUD.error(title: "Disconnect failed")
        }
    }
    
    func reloadPairing() {
        let activePairings: [Pairing] = Sign.instance.getSettledPairings()
        self.activePairings = activePairings
    }
    
    func setUpAuthSubscribing() {
        Sign.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .connected {
//                    self?.onClientConnected?()
                    print("Client connected")
                }
            }.store(in: &publishers)

        // TODO: Adapt proposal data to be used on the view
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal in
                print("[RESPONDER] WC: Did receive session proposal")
                self?.currentProposal = sessionProposal
                
                let appMetadata = sessionProposal.proposer
                let requiredNamespaces = sessionProposal.requiredNamespaces
                let info = SessionInfo(
                    name: appMetadata.name,
                    descriptionText: appMetadata.description,
                    dappURL: appMetadata.url,
                    iconURL: appMetadata.icons.first ?? "",
                    chains: requiredNamespaces["flow"]?.chains ?? [],
                    methods: requiredNamespaces["flow"]?.methods ?? [],
                    pendingRequests: [],
                    data: "")
                self?.currentSessionInfo = info
                Router.route(to: RouteMap.WalletConnect.approve(info, {
                    self?.approveSession(proposal: sessionProposal)
                }, {
                    self?.rejectSession(proposal: sessionProposal)
                }))
            }.store(in: &publishers)

        Sign.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadActiveSessions()
            }.store(in: &publishers)

        Sign.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                print("[RESPONDER] WC: Did receive session request")
                
                
                switch sessionRequest.method {
                case FCLWalletConnectMethod.authn.rawValue:
                    let address = WalletManager.shared.address.hex
                    let keyId = 0 // TODO: FIX ME with dynmaic keyIndex
                    let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                               data: AuthnData(addr: address, fType: "AuthnResponse", fVsn: "1.0.0",
                                                               services: [
                                                                serviceDefinition(address: address, keyId: keyId, type: .authn),
                                                                serviceDefinition(address: address, keyId: keyId, type: .authz),
                                                                serviceDefinition(address: address, keyId: keyId, type: .userSignature)
                                                               ]),
                                               reason: nil,
                                               compositeSignature: nil)
                    let response = JSONRPCResponse<AnyCodable>(id: sessionRequest.id, result: AnyCodable(result))
                    
                    Task {
                        do {
                            try await Sign.instance.respond(topic: sessionRequest.topic, response: .response(response))
                        } catch {
                            print("[WALLET] Respond Error: \(error.localizedDescription)")
                        }
                    }
                    
                case FCLWalletConnectMethod.authz.rawValue:
                    
                    do {
                        self?.currentRequest = sessionRequest
                        let jsonString = try sessionRequest.params.get([String].self)
                        let data = jsonString[0].data(using: .utf8)!
                        let model = try JSONDecoder().decode(Signable.self, from: data)

                        if let session = self?.activeSessions.first(where: { $0.topic == sessionRequest.topic }) {
                            let request = RequestInfo(cadence: model.cadence ?? "", agrument: model.args, name: session.peer.name, descriptionText: session.peer.description, dappURL: session.peer.url, iconURL: session.peer.icons.first ?? "", chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                            self?.currentRequestInfo = request
                            
                            Router.route(to: RouteMap.WalletConnect.request(request, {
                                self?.approveRequest(request: sessionRequest, requestInfo: request)
                            }, {
                                self?.rejectRequest(request: sessionRequest)
                            }))
                        }
                        
                    } catch {
                        print(error)
                        
                        Task {
                            do {
                                try await Sign.instance.respond(topic: sessionRequest.topic, response: .error(.init(id: 0, error: .init(code: 0, message: "NOT Handle"))))
                            } catch {
                                print("[WALLET] Respond Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                case FCLWalletConnectMethod.userSignature.rawValue:
                    
                    do {
                        self?.currentRequest = sessionRequest
                        let jsonString = try sessionRequest.params.get([String].self)
                        let data = jsonString[0].data(using: .utf8)!
                        let model = try JSONDecoder().decode(SignableMessage.self, from: data)
                        if let session = self?.activeSessions.first(where: { $0.topic == sessionRequest.topic }) {
                            let request = RequestMessageInfo(name: session.peer.name, descriptionText: session.peer.description, dappURL: session.peer.url, iconURL: session.peer.icons.first ?? "", chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                            self?.currentMessageInfo = request
                            
                            Router.route(to: RouteMap.WalletConnect.requestMessage(request, {
                                self?.approveRequestMessage(request: sessionRequest, requestInfo: request)
                            }, {
                                self?.rejectRequest(request: sessionRequest)
                            }))
                        }
                    } catch {
                        print(error)
                        
                        Task {
                            do {
                                try await Sign.instance.respond(topic: sessionRequest.topic, response: .error(.init(id: 0, error: .init(code: 0, message: "NOT Handle"))))
                            } catch {
                                print("[WALLET] Respond Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                default:
                    Task {
                        do {
                            try await Sign.instance.respond(topic: sessionRequest.topic, response: .error(.init(id: 0, error: .init(code: 0, message: "NOT Handle"))))
                        } catch {
                            print("[WALLET] Respond Error: \(error.localizedDescription)")
                        }
                    }
                }

            }.store(in: &publishers)

        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                self?.reloadActiveSessions()
            }.store(in: &publishers)
        
        Sign.instance.sessionEventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                print("[RESPONDER] WC: sessionEventPublisher")
//                self?.showSessionRequest(sessionRequest)
            }.store(in: &publishers)
        
        Sign.instance.sessionUpdatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                print("[RESPONDER] WC: sessionUpdatePublisher")
//                self?.showSessionRequest(sessionRequest)
            }.store(in: &publishers)
    }
}

// MARK: - Action

extension WalletConnectManager {
    private func approveSession(proposal: Session.Proposal) {
        Router.dismiss()
        
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        var sessionNamespaces = [String: SessionNamespace]()
        proposal.requiredNamespaces.forEach {
            let caip2Namespace = $0.key
            let proposalNamespace = $0.value
            let accounts = Set(proposalNamespace.chains.compactMap { WalletConnectSign.Account($0.absoluteString + ":\(account)") } )
            
            let extensions: [SessionNamespace.Extension]? = proposalNamespace.extensions?.map { element in
                let accounts = Set(element.chains.compactMap { WalletConnectSign.Account($0.absoluteString + ":\(account)") } )
                return SessionNamespace.Extension(accounts: accounts, methods: element.methods, events: element.events)
            }
            let sessionNamespace = SessionNamespace(accounts: accounts, methods: proposalNamespace.methods, events: proposalNamespace.events, extensions: extensions)
            sessionNamespaces[caip2Namespace] = sessionNamespace
        }
        
        let namespaces = sessionNamespaces
        
        Task {
            do {
                try await Sign.instance.approve(proposalId: proposal.id, namespaces: namespaces)
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveSession failed: \(error)")
                HUD.error(title: "approve_failed".localized)
            }
        }
    }
    
    private func rejectSession(proposal: Session.Proposal) {
        Router.dismiss()
        
        Task {
            do {
                try await Sign.instance.reject(proposalId: proposal.id, reason: .disapprovedChains)
                HUD.success(title: "rejected".localized)
            } catch {
                HUD.error(title: "reject_failed".localized)
            }
        }
    }
    
    private func approveRequest(request: Request, requestInfo: RequestInfo) {
        Router.dismiss()
        
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        Task {
            do {
                let data = Data(requestInfo.message.hexValue)
                let signedData = try await WalletManager.shared.sign(signableData: data)
                let signature = signedData.hexValue
                let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                           data: AuthnData(addr: account, fType: "CompositeSignature", fVsn: "1.0.0", services: nil, keyId: 0, signature: signature),
                                           reason: nil,
                                           compositeSignature: nil)
                let response = JSONRPCResponse<AnyCodable>(id: request.id, result: AnyCodable(result))
                try await Sign.instance.respond(topic: request.topic, response: .response(response))
                
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveRequest failed: \(error)")
                HUD.error(title: "approve_failed".localized)
                
                do {
                    try await Sign.instance.respond(topic: request.topic, response: .error(.init(id: 0, error: .init(code: 0, message: error.localizedDescription))))
                } catch {
                    debugPrint("WalletConnectManager -> approveRequest, report error failed: \(error)")
                }
            }
        }
    }
    
    private func rejectRequest(request: Request) {
        Router.dismiss()
        
        let reason = "User reject request"
        let response = JSONRPCResponse<AnyCodable>(id: request.id, result: AnyCodable(reason))
        
        Task {
            do {
                try await Sign.instance.respond(topic: request.topic, response: .response(response))
                HUD.success(title: "rejected".localized)
            } catch {
                debugPrint("WalletConnectManager -> rejectRequest failed: \(error)")
                HUD.error(title: "reject_failed".localized)
            }
        }
    }
    
    private func approveRequestMessage(request: Request, requestInfo: RequestMessageInfo) {
        Router.dismiss()
        
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        Task {
            do {
                let data = Flow.DomainTag.user.normalize + Data(requestInfo.message.hexValue)
                let signedData = try await WalletManager.shared.sign(signableData: data)
                let signature = signedData.hexValue
                let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                           data: AuthnData(addr: account, fType: "CompositeSignature", fVsn: "1.0.0", services: nil, keyId: 0, signature: signature),
                                           reason: nil,
                                           compositeSignature: nil)
                let response = JSONRPCResponse<AnyCodable>(id: request.id, result: AnyCodable(result))
                try await Sign.instance.respond(topic: request.topic, response: .response(response))
                
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveRequestMessage failed: \(error)")
                HUD.error(title: "approve_failed".localized)
                
                do {
                    try await Sign.instance.respond(topic: request.topic, response: .error(.init(id: 0, error: .init(code: 0, message: error.localizedDescription))))
                } catch {
                    debugPrint("WalletConnectManager -> approveRequestMessage, report error failed: \(error)")
                }
            }
        }
    }
}
