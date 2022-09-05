//
//  GasManager.swift
//  Lilico
//
//  Created by Selina on 5/9/2022.
//

import UIKit
import Flow

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    
    var config: Config!
    
    var isFailed: Bool = false
    
    var freeGasEnabled: Bool {
        !isFailed && config.features.freeGas
    }
    
    var payer: String {
        if !freeGasEnabled {
            return WalletManager.shared.getPrimaryWalletAddress() ?? ""
        }
        if LocalUserDefaults.shared.flowNetwork.toFlowType() == .mainnet {
            return config.payer.mainnet.address
        }
        return config.payer.testnet.address
    }
    
    var payerKeyId: Int {
        if !freeGasEnabled {
            return 0
        }
        if LocalUserDefaults.shared.flowNetwork.toFlowType() == .mainnet {
            return config.payer.mainnet.keyID
        }
        return config.payer.testnet.keyID

    }
    
    init() {
        Task {
            do {
                let config: Config = try await FirebaseConfig.config.fetch(decoder: JSONDecoder())
                self.config = config
            } catch {
                do {
                    let config: Config = try await FirebaseConfig.config.fetchLocal()
                    self.config = config
                } catch {
                    self.isFailed = true
                }
            }
        }
    }
}

extension RemoteConfigManager: FlowSigner {
    
    var address: Flow.Address {
        .init(hex: payer)
    }
    
    var hashAlgo: Flow.HashAlgorithm {
        .SHA2_256
    }
    
    var signatureAlgo: Flow.SignatureAlgorithm {
        .ECDSA_P256
    }
    
    var keyIndex: Int {
        payerKeyId
    }
    
    func sign(transaction: Flow.Transaction, signableData: Data) async throws -> Data {
        let request = SignPayerRequest(transaction: transaction.voucher, message: .init(envelopeMessage: signableData.hexValue))
        let signature:SignPayerResponse = try await Network.requestWithRawModel(FirebaseAPI.signAsPayer(request))
        return Data(hex: signature.envelopeSigs.sig)
    }
}
