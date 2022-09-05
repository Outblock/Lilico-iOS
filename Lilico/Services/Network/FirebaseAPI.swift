//
//  FirebaseAPI.swift
//  Lilico
//
//  Created by Hao Fu on 5/9/2022.
//

import Foundation
import Moya
import Flow
import BigInt

enum FirebaseAPI {
    case signAsPayer(SignPayerRequest)
    case moonPay(MoonPayRequest)
}

struct MoonPayRequest: Codable {
    let url: String
}

struct FCLVoucher: Codable {
    let cadence: Flow.Script
    let payer: Flow.Address
    let refBlock: Flow.ID
    let proposalKey: ProposalKey
    let computeLimit: BigUInt
    let authorizers: [Flow.Address]
    let payloadSigs: [Signature]
    
    struct ProposalKey: Codable {
        let address: Flow.Address
        let keyId: Int
        let sequenceNum: BigInt
    }
    
    struct Signature: Codable {
        let address: Flow.Address
        let keyId: Int
        let sig: String
    }
}

struct SignPayerResponse: Codable {
    let envelopeSigs: FCLVoucher.Signature
}

struct SignPayerRequest: Codable {
    let transaction: FCLVoucher
    let message: PayerMessage
}

struct PayerMessage: Codable {
    let envelopeMessage: String
    
    enum CodingKeys: String, CodingKey {
        case envelopeMessage = "envelope_message"
    }
}


extension Flow.Transaction {
    var voucher: FCLVoucher {
        FCLVoucher(cadence: script,
                   payer: payer,
                   refBlock: referenceBlockId,
                   proposalKey: FCLVoucher.ProposalKey(address: proposalKey.address,
                                                       keyId: proposalKey.keyIndex,
                                                       sequenceNum: proposalKey.sequenceNumber),
                   computeLimit: gasLimit,
                   authorizers: authorizers,
                   payloadSigs: payloadSignatures.compactMap{
            FCLVoucher.Signature(address: $0.address,
                                 keyId: $0.keyIndex,
                                 sig: $0.signature.hexValue)
        })
    }
}

extension FirebaseAPI: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
#if LILICOPROD
        .init(string: "https://us-central1-lilico-334404.cloudfunctions.net")!
#else
        .init(string: "https://us-central1-lilico-dev.cloudfunctions.net")!
#endif
    }

    var path: String {
        switch self {
        case .signAsPayer:
            return "/signAsPayer"
        case .moonPay:
            return "/moonPaySignature"
        }
    }

    var method: Moya.Method {
        switch self {
        case .moonPay, .signAsPayer:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .moonPay(request):
            return .requestCustomJSONEncodable(request, encoder: JSONEncoder())
        case let .signAsPayer(request):
            return .requestCustomJSONEncodable(request, encoder: JSONEncoder())
        }
    }

    var headers: [String: String]? {
        return LilicoAPI.commonHeaders
    }
}
