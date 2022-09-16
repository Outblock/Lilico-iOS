//
//  ClaimDomainViewModel.swift
//  Lilico
//
//  Created by Selina on 16/9/2022.
//

import SwiftUI
import Flow

class ClaimDomainViewModel: ObservableObject {
    @Published var username: String? = UserManager.shared.userInfo?.username
    
    func claimAction() {
        guard username != nil else {
            return
        }
        
        let successBlock: (String) -> () = { txId in
            DispatchQueue.main.async {
                let holder = TransactionManager.TransactionHolder(id: Flow.ID(hex: txId), type: .claimDomain, data: Data())
                TransactionManager.shared.newTransaction(holder: holder)
                
                HUD.dismissLoading()
                Router.pop()
            }
        }
        
        let failureBlock = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                HUD.error(title: "claim_domain_failed".localized)
            }
        }
        
        HUD.loading()
        
        Task {
            do {
                let prepareResponse: ClaimDomainPrepareResponse = try await Network.request(LilicoAPI.Flowns.domainPrepare)
                let request = try await buildPayerSignableRequest(response: prepareResponse)
                let signatureResponse: ClaimDomainSignatureResponse = try await Network.request(LilicoAPI.Flowns.domainSignature(request))
                
                guard let txId = signatureResponse.txId, !txId.isEmpty else {
                    debugPrint("ClaimDomainViewModel -> claimAction txId is empty")
                    failureBlock()
                    return
                }
                
                if TransactionManager.shared.isExist(tid: txId) {
                    failureBlock()
                    return
                }
                
                successBlock(txId)
            } catch {
                debugPrint("ClaimDomainViewModel -> claimAction failed: \(error)")
                failureBlock()
            }
        }
    }
    
    private func buildPayerSignableRequest(response: ClaimDomainPrepareResponse) async throws -> SignPayerRequest {
        let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        
        var transaction = try await flow.buildTransaction {
            cadence {
                response.cadence ?? ""
            }
            
            arguments {
                [.string(username ?? "")]
            }
            
            gasLimit {
                9999
            }
            
            proposer {
                Flow.Address(hex: address)
            }
            
            authorizers {
                [Flow.Address(hex: address), Flow.Address(hex: response.lilicoServerAddress ?? ""), Flow.Address(hex: response.flownsServerAddress ?? "")]
            }
            
            payer {
                RemoteConfigManager.shared.payer
            }
        }
        
        let signedTransaction = try await transaction.signPayload(signers: [WalletManager.shared, RemoteConfigManager.shared])
        
        return signedTransaction.buildSignPayerRequest()
    }
}

extension Flow.Transaction {
    func buildSignPayerRequest() -> SignPayerRequest {
        let pKey = FCLVoucher.ProposalKey(address: proposalKey.address, keyId: proposalKey.keyIndex, sequenceNum: UInt64(proposalKey.sequenceNumber))
        let payloadSigs = payloadSignatures.map { FCLVoucher.Signature(address: $0.address, keyId: $0.keyIndex, sig: $0.signature.hexValue) }
        
        let voucher = FCLVoucher(cadence: script, payer: payer, refBlock: referenceBlockId, arguments: arguments, proposalKey: pKey, computeLimit: UInt64(gasLimit), authorizers: authorizers, payloadSigs: payloadSigs)
     
        let msg = signablePlayload?.hexValue ?? ""
        let request = SignPayerRequest(transaction: voucher, message: PayerMessage(envelopeMessage: msg))
        
        return request
    }
}
