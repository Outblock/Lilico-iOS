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

class WalletConnectManager: ObservableObject {
    static let shared = WalletManager()
    
    @Published
    var sessionItems: [ActiveSessionItem] = []
    
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
            url: "https://lilico.app",
            icons: ["https://lilico.app/logo.png"])
        Sign.configure(metadata: metadata, projectId: "1dd2dfa085b9cf69ad5d316bfc11999f", socketFactory: SocketFactory())
        reloadActiveSessions()
        setUpAuthSubscribing()
    }
    
    func connect(link: String) {
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
        sessionItems = settledSessions.map { session -> ActiveSessionItem in
            let app = session.peer
            return ActiveSessionItem(
                dappName: app.name,
                dappURL: app.url,
                iconURL: app.icons.first ?? "",
                topic: session.topic)
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
//                DispatchQueue.main.async {
//                    self?.showPopUp = true
//                }
                
//                    self?.showSessionProposal(Proposal(proposal: sessionProposal)) // FIXME: Remove mock
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

                        if let session = self?.sessionItems.first{ $0.topic == sessionRequest.topic } {
                            let request = RequestInfo(cadence: model.cadence ?? "", agrument: model.args, name: session.dappName, descriptionText: session.dappURL, dappURL: session.dappURL, iconURL: session.iconURL, chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                            self?.currentRequestInfo = request
//                            DispatchQueue.main.async {
//                                self?.showRequestPopUp = true
//                            }
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
                        if let session = self?.sessionItems.first{ $0.topic == sessionRequest.topic } {
                            let request = RequestMessageInfo(name: session.dappName, descriptionText: session.dappURL, dappURL: session.dappURL, iconURL: session.iconURL, chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                            self?.currentMessageInfo = request
//                            DispatchQueue.main.async {
//                                self?.showRequestMessagePopUp = true
//                            }
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
