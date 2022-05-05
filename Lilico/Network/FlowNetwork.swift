//
//  FlowNetwork.swift
//  Lilico
//
//  Created by Hao Fu on 30/4/2022.
//

import Foundation
import Flow
import Combine

class FlowNetwork {
    
    func isTokenListEnabled(address: Flow.Address, tokens: [TokenModel]) -> Future<[Bool], Error> {
        let network = flow.chainID
            
        let cadence =  FlowScriptArgument.checkEnable.tokenEnable(with: tokens, at: network)
        let call = flow.accessAPI.executeScriptAtLatestBlock(script: Flow.Script(text: cadence),
                                                        arguments: [.init(value: .address(address))])
        return call
            .toFuture()
            .tryMap { response in
                guard let fields = response.fields, let array = fields.value.toArray() else {
                    throw LLError.emptyWallet
                }
                return array.compactMap { $0.value.toBool() }
            }
            .asFuture()
    }
}

