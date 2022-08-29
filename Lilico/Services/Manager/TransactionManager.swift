//
//  TransactionManager.swift
//  Lilico
//
//  Created by Selina on 25/8/2022.
//

import UIKit
import Flow

extension Flow.Transaction.Status {
    var progressPercent: CGFloat {
        switch self {
        case .pending, .unknown:
            return 0.25
        case .finalized:
            return 0.5
        case .executed:
            return 0.75
        case .sealed:
            return 1.0
        default:
            return 0
        }
    }
}

extension TransactionManager {
    enum TransactionType: Int, Codable {
        case common
        case transferCoin
        case addToken
        case addCollection
        case transferNFT
    }
    
    enum InternalStatus: Int, Codable {
        case pending
        case success
        case failed
    }
    
    class TransactionHolder: Codable {
        var transactionId: Flow.ID
        var createTime: TimeInterval
        var status: Int = Flow.Transaction.Status.pending.rawValue
        var internalStatus: TransactionManager.InternalStatus = .pending
        var type: TransactionManager.TransactionType
        var data: Data
        
        private var timer: Timer?
        private var retryTimes: Int = 0
        
        var flowStatus: Flow.Transaction.Status {
            return Flow.Transaction.Status(status)
        }
        
        enum CodingKeys: String, CodingKey {
            case transactionId
            case createTime
            case status
            case type
            case data
            case internalStatus
        }
        
        init(id: Flow.ID, createTime: TimeInterval = Date().timeIntervalSince1970, type: TransactionManager.TransactionType, data: Data) {
            self.transactionId = id
            self.createTime = createTime
            self.type = type
            self.data = data
        }
        
        func decodedObject<T: Decodable>(_ type: T.Type) -> T? {
            return try? JSONDecoder().decode(type, from: data)
        }
        
        func icon() -> URL? {
            switch type {
            case .transferCoin:
                guard let model = decodedObject(CoinTransferModel.self), let token = WalletManager.shared.getToken(bySymbol: model.symbol) else {
                    return nil
                }
                
                return token.icon
            case .addToken:
                return decodedObject(TokenModel.self)?.icon
            case .addCollection:
                return decodedObject(NFTCollectionInfo.self)?.logoURL
            case .transferNFT:
                return decodedObject(NFTTransferModel.self)?.nft.logoUrl
            default:
                return nil
            }
        }
        
        func startTimer() {
            stopTimer()
            
            if retryTimes > 5 {
                internalStatus = .failed
                postNotification()
                return
            }
            
            let timer = Timer(timeInterval: 2, target: self, selector: #selector(onCheck), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
            
            debugPrint("TransactionHolder -> startTimer")
        }
        
        func stopTimer() {
            if let timer = timer {
                timer.invalidate()
                self.timer = nil
                debugPrint("TransactionHolder -> stopTimer")
            }
        }
        
        @objc private func onCheck() {
            debugPrint("TransactionHolder -> onCheck")
            
            Task {
                do {
                    let result = try await FlowNetwork.getTransactionResult(by: transactionId.hex)
                    debugPrint("TransactionHolder -> onCheck status: \(result.status)")
                    
                    DispatchQueue.main.async {
                        if result.status == self.flowStatus {
                            self.startTimer()
                            return
                        }
                        
                        self.status = result.status.rawValue
                        if result.isFailed && !result.errorMessage.hasPrefix("[Error Code: 1007]") {
                            self.internalStatus = .failed
                            debugPrint("TransactionHolder -> onCheck result failed: \(result.errorMessage)")
                        } else if result.isComplete {
                            self.internalStatus = .success
                        } else {
                            self.internalStatus = .pending
                            self.startTimer()
                        }
                        
                        self.postNotification()
                    }
                } catch {
                    debugPrint("TransactionHolder -> onCheck failed: \(error)")
                    DispatchQueue.main.async {
                        self.retryTimes += 1
                        self.startTimer()
                    }
                }
            }
        }
        
        private func postNotification() {
            debugPrint("TransactionHolder -> postNotification status: \(status)")
            NotificationCenter.default.post(name: .transactionStatusDidChanged, object: self)
        }
    }
}

class TransactionManager {
    static let shared = TransactionManager()
    
    private lazy var rootFolder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("transaction_cache")
    private lazy var transactionCacheFile = rootFolder.appendingPathComponent("transaction_cache_file")
    
    private(set) var holders: [TransactionHolder] = []
    
    init() {
        checkFolder()
        addNotification()
        loadHoldersFromCache()
        startCheckIfNeeded()
    }
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderChanged(noti:)), name: .transactionStatusDidChanged, object: nil)
    }
    
    @objc private func onHolderChanged(noti: Notification) {
        guard let holder = noti.object as? TransactionHolder else {
            return
        }
        
        if holder.internalStatus == .pending {
            return
        }
        
        if holder.internalStatus == .failed {
            removeTransaction(id: holder.transactionId.hex)
            HUD.error(title: "transaction_failed".localized)
            return
        }
        
        HUD.success(title: "transaction_success".localized)
        
        removeTransaction(id: holder.transactionId.hex)
        
        switch holder.type {
        case .transferCoin:
            Task {
                try? await WalletManager.shared.fetchBalance()
            }
        case .addToken:
            Task {
                try? await WalletManager.shared.fetchWalletDatas()
            }
        default:
            break
        }
    }
    
    private func startCheckIfNeeded() {
        for holder in holders {
            holder.startTimer()
        }
    }
    
    private func postDidChangedNotification() {
        DispatchQueue.syncOnMain {
            NotificationCenter.default.post(name: .transactionManagerDidChanged, object: nil)
        }
    }
}

// MARK: - Public

extension TransactionManager {
    func newTransaction(holder: TransactionManager.TransactionHolder) {
        holders.insert(holder, at: 0)
        saveHoldersToCache()
        postDidChangedNotification()
        
        holder.startTimer()
    }
    
    func removeTransaction(id: String) {
        for holder in holders {
            if holder.transactionId.hex == id {
                holder.stopTimer()
            }
        }
        
        holders.removeAll { $0.transactionId.hex == id }
        saveHoldersToCache()
        postDidChangedNotification()
    }
    
    func isTokenEnabling(symbol: String) -> Bool {
        for holder in holders {
            if holder.type == .addToken, let token = holder.decodedObject(TokenModel.self), token.symbol == symbol {
                return true
            }
        }
        
        return false
    }
}

// MARK: - Cache

extension TransactionManager {
    private func checkFolder() {
        do {
            if !FileManager.default.fileExists(atPath: rootFolder.relativePath) {
                try FileManager.default.createDirectory(at: rootFolder, withIntermediateDirectories: true)
            }
            
        } catch {
            debugPrint("TransactionManager -> checkFolder error: \(error)")
        }
    }
    
    private func loadHoldersFromCache() {
        if !FileManager.default.fileExists(atPath: transactionCacheFile.relativePath) {
            return
        }
        
        do {
            let data = try Data(contentsOf: transactionCacheFile)
            let list = try JSONDecoder().decode([TransactionManager.TransactionHolder].self, from: data)
            let filterdList = list.filter { $0.internalStatus == .pending }
            
            if !filterdList.isEmpty {
                holders = filterdList
            }
        } catch {
            debugPrint("TransactionManager -> loadHoldersFromCache error: \(error)")
        }
    }
    
    private func saveHoldersToCache() {
        let filterdHolders = holders.filter { $0.internalStatus == .pending }
        
        do {
            let data = try JSONEncoder().encode(filterdHolders)
            try data.write(to: transactionCacheFile)
        } catch {
            debugPrint("TransactionManager -> saveHoldersToCache error: \(error)")
        }
    }
}
