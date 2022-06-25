//
//  Lilico_liteTests.swift
//  Lilico-liteTests
//
//  Created by Hao Fu on 26/11/21.
//

@testable import Lilico
import XCTest
import Flow

class Lilico_liteTests: XCTestCase {
    func testExample() throws {}

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testAES() throws {
//        let string = try setAccountDatatoiCloud()
//        print(string)
    }

    func testAESS() {
        let data = try! WalletManager.encryptionAES(key: "passwr", data: "123".data(using: .utf8)!)
        print(data.hexValue)
    }

//    func setAccountDatatoiCloud(name: String = "lilico", secret: String = "lilico-secert") throws -> String {
//        let data = secret.data(using: .utf8)!
//        let encryptData = try WalletManager.encryptionAES(key: name, data: data)
//        let accountData = BackupManager.AccountData(data: encryptData.hexValue, address: ["0x123123123"], name: name)
//        let jsonData = try JSONEncoder().encode(accountData)
//        let storeData = try WalletManager.encryptionAES(key: WalletManager.encryptionKey, data: jsonData)
//        let finalData = BackupManager.StoreData(users: [name], data: [storeData.base64EncodedString()])
//        let finalJsonData = try JSONEncoder().encode(finalData)
//        return finalJsonData.base64EncodedString()
//    }
//
//    func loadAccountDataFromiCloud(dataString: String) throws -> String {
//        guard let data = Data(base64Encoded: dataString) else {
//            throw LLError.decryptBackupFailed
//        }
//
//        let model = try JSONDecoder().decode(BackupManager.StoreData.self, from: data)
//        guard let storeString = model.data.first,
//              let storeData = Data(base64Encoded: storeString)
//        else {
//            throw LLError.decryptBackupFailed
//        }
//
//        let jsonData = try WalletManager.decryptionAES(key: WalletManager.encryptionKey, data: storeData)
//        let accountData = try JSONDecoder().decode(BackupManager.AccountData.self, from: jsonData)
//        let encryptData = try WalletManager.decryptionAES(key: accountData.name, data: storeData)
//        let secret = String(data: encryptData, encoding: .utf8)!
//        return secret
//    }
    
    func testV2NFTCollection() async throws {
        
//        FlowNetwork.checkCollectionEnable(address: <#T##Flow.Address#>, list: <#T##[NFTCollection]#>)
        
        let address = Flow.Address(hex: "0x2b06c41f44a05656")
        
        let list: [NFTCollection] = try await FirebaseConfig.nftCollections.fetch()
        
        var dict = [String : Bool]()
        
        flow.configure(chainID: .mainnet)
        
        for nft in list {
            let result: [Bool] = try await FlowNetwork.checkCollectionEnable(address: address, list: [nft])
            dict[nft.name] = result.first!
        }
        
        print(dict)
    }
}
