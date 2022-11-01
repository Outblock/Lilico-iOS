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
import UIKit
import WalletConnectPairing
import WalletConnectNetworking

class WalletConnectManager: ObservableObject {
    static let shared = WalletConnectManager()
    
    @Published
    var activeSessions: [Session] = []
    
    @Published
    var activePairings: [Pairing] = []
    
    @Published var pendingRequests: [WalletConnectSign.Request] = []
    
    var onClientConnected: (() -> Void)?
    
    private var publishers = [AnyCancellable]()
    private var pendingRequestCheckTimer: Timer?
    
    
    var currentProposal: Session.Proposal?
    var currentRequest: WalletConnectSign.Request?
    var currentSessionInfo: SessionInfo?
    var currentRequestInfo: RequestInfo?
    var currentMessageInfo: RequestMessageInfo?
    
    let metadata = AppMetadata(
        name: "Lilico",
        description: "A crypto wallet on Flow built for Explorers, Collectors and Gamers",
        url: "https://link.lilico.app",
        icons: ["https://lilico.app/logo.png"])
    
    let projectId = "29b38ec12be4bd19bf03d7ccef29aaa6"
    
    init() {
        Networking.configure(projectId: projectId, socketFactory: SocketFactory())
        Pair.configure(metadata: metadata)
        
        reloadActiveSessions()
        reloadPairing()
        setUpAuthSubscribing()
        
        //        #if DEBUG
        //        try? Sign.instance.cleanup()
        //        #endif
        
        UserManager.shared.$isLoggedIn.sink { [weak self] _ in
            DispatchQueue.main.async {
                if UserManager.shared.isLoggedIn {
                    self?.startPendingRequestCheckTimer()
                } else {
                    self?.stopPendingRequestCheckTimer()
                    self?.pendingRequests = []
                }
            }
        }.store(in: &publishers)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPendingRequests), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func connect(link: String) {
        debugPrint("WalletConnectManager -> connect(), Thread: \(Thread.isMainThread)")
        print("[RESPONDER] Pairing to: \(link)")
        Task {
            do {
                if let uri = WalletConnectURI.init(string: link) {
                    
                    //                    if Sign.instance.getPairings().contains(where: { $0.topic == uri.topic }) {
                    //                        try await Sign.instance.disconnect(topic: uri.topic)
                    //                    }
                    try await Pair.instance.pair(uri: uri)
                }
            } catch {
                print("[PROPOSER] Pairing connect error: \(error)")
                HUD.error(title: "Connect failed")
            }
        }
        onClientConnected = nil
    }
    
    
    func reloadActiveSessions() {
        let settledSessions = Sign.instance.getSessions()
        DispatchQueue.main.async {
            self.activeSessions = settledSessions
        }
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
        let activePairings: [Pairing] = Pair.instance.getPairings()
        self.activePairings = activePairings
    }
    
    func encodeAccountProof(address: String, nonce: String, appIdentifier: String, includeDomaintag: Bool = true) -> Data? {
        let list: [Any] = [appIdentifier.data(using: .utf8) ?? Data(), Data(hex: address), Data(hex: nonce)]
        guard let rlp = RLP.encode(list) else {
            return nil
        }
        
        let accountProofTag = Flow.DomainTag.custom("FCL-ACCOUNT-PROOF-V0.0").normalize
        
        if includeDomaintag {
            return accountProofTag + rlp
        } else {
            return rlp
        }
    }
    
    func setUpAuthSubscribing() {
        Sign.instance.socketConnectionStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                if status == .connected {
                    self?.onClientConnected?()
                    print("Client connected")
                }
            }.store(in: &publishers)
        
        // TODO: Adapt proposal data to be used on the view
        Sign.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionProposal in
                print("[RESPONDER] WC: Did receive session proposal")
                self?.currentProposal = sessionProposal
                
                let pairings = Pair.instance.getPairings()
                if pairings.contains(where: { $0.peer == sessionProposal.proposer }) {
                    self?.approveSession(proposal: sessionProposal)
                    return
                }
                
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
                
                guard let chains = requiredNamespaces["flow"]?.chains,
                      let reference = chains.first(where: { $0.namespace == "flow" })?.reference else {
                    self?.rejectSession(proposal: sessionProposal)
                    return
                }
                
                let network = Flow.ChainID(name: reference.lowercased())
                
                let authnVM = BrowserAuthnViewModel(title: info.name,
                                                    url: info.dappURL,
                                                    logo: info.iconURL,
                                                    walletAddress: WalletManager.shared.getPrimaryWalletAddress(),
                                                    network: network ) { result in
                    if result {
                        // TODO: Handle network mismatch
                        self?.approveSession(proposal: sessionProposal)
                    } else {
                        self?.rejectSession(proposal: sessionProposal)
                    }
                }
                
                Router.route(to: RouteMap.Explore.authn(authnVM))
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
                
                self?.handleRequest(sessionRequest)
                
            }.store(in: &publishers)
        
        Sign.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                self?.reloadActiveSessions()
            }.store(in: &publishers)
        
        Sign.instance.sessionExtendPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sessionRequest in
                print("[RESPONDER] WC: sessionExtendPublisher")
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
    
    private func navigateBackTodApp(topic: String) {
        DispatchQueue.main.async {
            if  let session = self.activeSessions.first(where: { $0.topic == topic }),
                let url = URL(string: session.peer.url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}

// MARK: - Pending Request

extension WalletConnectManager {
    private func startPendingRequestCheckTimer() {
        stopPendingRequestCheckTimer()
        
        let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(reloadPendingRequests), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        
        self.pendingRequestCheckTimer = timer
    }
    
    private func stopPendingRequestCheckTimer() {
        if let timer = self.pendingRequestCheckTimer {
            timer.invalidate()
            self.pendingRequestCheckTimer = nil
        }
    }
    
    @objc func reloadPendingRequests() {
        if UserManager.shared.isLoggedIn {
            self.pendingRequests = Sign.instance.getPendingRequests()
        }
    }
}

// MARK: - Handle

extension WalletConnectManager {
    func handleRequest(_ sessionRequest: WalletConnectSign.Request) {
        let address = WalletManager.shared.address.hex.addHexPrefix()
        let keyId = 0 // TODO: FIX ME with dynmaic keyIndex
        
        switch sessionRequest.method {
        case FCLWalletConnectMethod.authn.rawValue:
            
            Task {
                do {
                    let jsonString = try sessionRequest.params.get([String].self)
                    let data = jsonString[0].data(using: .utf8)!
                    
                    var services = [
                        // Since fcl-js is not implement pre-authz, hence we disable it for now
//                        serviceDefinition(address: RemoteConfigManager.shared.payer, keyId: RemoteConfigManager.shared.keyIndex, type: .preAuthz),
                        serviceDefinition(address: address, keyId: keyId, type: .authn),
                        serviceDefinition(address: address, keyId: keyId, type: .authz),
                        serviceDefinition(address: address, keyId: keyId, type: .userSignature)
                    ]
                    
                    if let model = try? JSONDecoder().decode(BaseConfigRequest.self, from: data),
                       let nonce = model.accountProofNonce,
                       let appIdentifier = model.appIdentifier,
                       let data = self.encodeAccountProof(address: address, nonce: nonce, appIdentifier: appIdentifier),
                       let signedData = try? await WalletManager.shared.sign(signableData: data) {
                        
                        services.append(accountProofServiceDefinition(address: address, keyId: keyId, nonce: nonce, signature: signedData.hexValue))
                    }
                    
                    let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                               data: AuthnData(addr: address, fType: "AuthnResponse", fVsn: "1.0.0",
                                                               services: services),
                                               reason: nil,
                                               compositeSignature: nil)
                    try await Sign.instance.respond(topic: sessionRequest.topic, requestId: sessionRequest.id, response: .response(AnyCodable(result)))
                    self.navigateBackTodApp(topic: sessionRequest.topic)
                } catch {
                    print("[WALLET] Respond Error: \(error.localizedDescription)")
                    rejectRequest(request: sessionRequest)
                }
            }
            
        case FCLWalletConnectMethod.preAuthz.rawValue:
            
            let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                       data: AuthnData(addr: address, fType: "AuthnResponse", fVsn: "1.0.0",
                                                       services: nil,
                                                       proposer: serviceDefinition(address: address, keyId: keyId, type: .authz),
                                                       payer:
                                                        [serviceDefinition(address: RemoteConfigManager.shared.payer, keyId: RemoteConfigManager.shared.keyIndex, type: .authz)],
                                                       authorization:[serviceDefinition(address: address, keyId: keyId, type: .authz)]
                                                      ),
                                       reason: nil,
                                       compositeSignature: nil)
            
            Task {
                do {
                    try await Sign.instance.respond(topic: sessionRequest.topic, requestId: sessionRequest.id, response: .response(AnyCodable(result)))
                } catch {
                    print("[WALLET] Respond Error: \(error.localizedDescription)")
                    rejectRequest(request: sessionRequest)
                }
            }
            
        case FCLWalletConnectMethod.authz.rawValue:
            
            do {
                self.currentRequest = sessionRequest
                let jsonString = try sessionRequest.params.get([String].self)
                let data = jsonString[0].data(using: .utf8)!
                let model = try JSONDecoder().decode(Signable.self, from: data)
                print(model.roles)
                
                if model.roles.payer && !model.roles.proposer && !model.roles.authorizer {
                    self.approvePayerRequest(request: sessionRequest, model: model, message: model.message)
                    self.navigateBackTodApp(topic: sessionRequest.topic)
                    return
                }
                
                if let session = self.activeSessions.first(where: { $0.topic == sessionRequest.topic }) {
                    let request = RequestInfo(cadence: model.cadence ?? "", agrument: model.args, name: session.peer.name, descriptionText: session.peer.description, dappURL: session.peer.url, iconURL: session.peer.icons.first ?? "", chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                    
                    self.currentRequestInfo = request
                    
                    let authzVM = BrowserAuthzViewModel(title: request.name, url: request.dappURL, logo: request.iconURL, cadence: request.cadence) { result in
                        if result {
                            self.approveRequest(request: sessionRequest, requestInfo: request)
                        } else {
                            self.rejectRequest(request: sessionRequest)
                        }
                    }
                    
                    Router.route(to: RouteMap.Explore.authz(authzVM))
                }
                
                if model.roles.payer {
                    self.navigateBackTodApp(topic: sessionRequest.topic)
                }
                
                
            } catch {
                print("[WALLET] Respond Error: \(error.localizedDescription)")
                rejectRequest(request: sessionRequest)
            }
            
        case FCLWalletConnectMethod.userSignature.rawValue:
            
            do {
                self.currentRequest = sessionRequest
                let jsonString = try sessionRequest.params.get([String].self)
                let data = jsonString[0].data(using: .utf8)!
                let model = try JSONDecoder().decode(SignableMessage.self, from: data)
                if let session = self.activeSessions.first(where: { $0.topic == sessionRequest.topic }) {
                    let request = RequestMessageInfo(name: session.peer.name, descriptionText: session.peer.description, dappURL: session.peer.url, iconURL: session.peer.icons.first ?? "", chains: Set(arrayLiteral: sessionRequest.chainId), methods: nil, pendingRequests: [], message: model.message)
                    self.currentMessageInfo = request
                    
                    let vm = BrowserSignMessageViewModel(title: request.name, url: request.dappURL, logo: request.iconURL, cadence: request.message) { result in
                        if result {
                            self.approveRequestMessage(request: sessionRequest, requestInfo: request)
                        } else {
                            self.rejectRequest(request: sessionRequest)
                        }
                        self.navigateBackTodApp(topic: sessionRequest.topic)
                    }
                    
                    Router.route(to: RouteMap.Explore.signMessage(vm))
                }
            } catch {
                print(error)
                rejectRequest(request: sessionRequest)
            }
            
        default:
            rejectRequest(request: sessionRequest, reason: "unspport method")
        }
    }
}

// MARK: - Action

extension WalletConnectManager {
    private func approveSession(proposal: Session.Proposal) {
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
        Task {
            do {
                try await Sign.instance.reject(proposalId: proposal.id, reason: .userRejected)
                HUD.success(title: "rejected".localized)
            } catch {
                HUD.error(title: "reject_failed".localized)
            }
        }
    }
    
    private func approveRequest(request: Request, requestInfo: RequestInfo) {
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
                
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(AnyCodable(result)))
                
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveRequest failed: \(error)")
                rejectRequest(request: request)
            }
        }
    }
    
    private func approvePayerRequest(request: Request, model: Signable, message: String) {
        guard let account = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        Task {
            do {
                let tx = model.voucher.toFCLVoucher()
                let data = Data(message.hexValue)
                let signedData = try await RemoteConfigManager.shared.sign(voucher: tx, signableData: data)
                let signature = signedData.hexValue
                let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .approved,
                                           data: AuthnData(addr: account, fType: "CompositeSignature", fVsn: "1.0.0", services: nil, keyId: 0, signature: signature),
                                           reason: nil,
                                           compositeSignature: nil)
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(AnyCodable(result)))
                
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveRequest failed: \(error)")
                rejectRequest(request: request)
            }
        }
    }
    
    private func rejectRequest(request: Request, reason: String = "User reject request") {
        let result = AuthnResponse(fType: "PollingResponse", fVsn: "1.0.0", status: .declined,
                                   reason: reason,
                                   compositeSignature: nil)
        
        Task {
            do {
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(AnyCodable(result)))
                HUD.success(title: "rejected".localized)
            } catch {
                debugPrint("WalletConnectManager -> rejectRequest failed: \(error)")
                HUD.error(title: "reject_failed".localized)
                rejectRequest(request: request)
            }
        }
    }
    
    private func approveRequestMessage(request: Request, requestInfo: RequestMessageInfo) {
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
                try await Sign.instance.respond(topic: request.topic, requestId: request.id, response: .response(AnyCodable(result)))
                HUD.success(title: "approved".localized)
            } catch {
                debugPrint("WalletConnectManager -> approveRequestMessage failed: \(error)")
                HUD.error(title: "approve_failed".localized)
                rejectRequest(request: request)
            }
        }
    }
}
