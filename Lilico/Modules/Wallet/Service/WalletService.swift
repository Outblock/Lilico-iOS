//
//  WalletService.swift
//  Lilico
//
//  Created by cat on 2022/5/9.
//

import Foundation
import Flow

struct WalletService {
    var enableTokens: [TokenModel] = []
    //TODO: 每个钱包的余额怎么保存
    private var balanceList:[Double] = []
    
    var walletName: String {
        return enableTokens.first?.name ?? ""
    }
    
    var totalBalance: String {
        let balance = balanceList.reduce(0.0) { $0 + $1 }
        return String(balance)
    }
    
    var address: String {
        return enableTokens.first?.address.addressByNetwork(flow.chainID) ?? ""
    }
    
    var flowAddress: Flow.Address!
    
    //MARK: fetch data
    mutating func fetchWallet() async throws {
        let allToken = await fetchAllToken()
        if(allToken.isEmpty) {
//            throw WalletError.none
        }
        let address = allToken.first?.address.testnet ?? ""
        flowAddress = Flow.Address(hex: address)
        await checkTokenEnableState(with: allToken)
        await refreshBalance()
        print("------********** \(enableTokens)")
    }
    
    
    private mutating func fetchAllToken() async -> [TokenModel]{
        do {
            let list = try await AppConfig.flowCoins.fetch()
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let allTokens = try decoder.decode([TokenModel].self, from: list)
            return allTokens
        }catch {
            print("❌「Error」fetch config from firebase failed!!!\n \(error)")
            return []
        }
    }
    
    private mutating func checkTokenEnableState(with tokens: [TokenModel]) async {
        do {
            enableTokens.removeAll()
            let tokenEnableResult = try await FlowNetwork.checkTokensEnable(address: flowAddress, tokens: tokens)
            for (index, value) in tokenEnableResult.enumerated() {
                if(value) {
                    enableTokens.append(tokens[index])
                }
            }
        }catch {
            print("❌「Error」refer token enable \n \(error)!!!")
        }
        
    }
    
    private mutating func refreshBalance() async {
        do {
            let result = try await FlowNetwork.fetchBalance(at: flowAddress, with: enableTokens)
            balanceList.removeAll()
            balanceList.append(contentsOf: result)
            print("------********** 请求的余额 \(result)");
        }
        catch{
            
        }
    }
    
}
