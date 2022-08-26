//
//  TransactionManager.swift
//  Lilico
//
//  Created by Selina on 25/8/2022.
//

import Foundation
import Flow

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
        var id: Flow.ID
        var createTime: TimeInterval
        var status: Flow.Transaction.Status
        var internalStatus: TransactionManager.InternalStatus
        var type: TransactionManager.TransactionType
        var data: Data
        
        private var timer: Timer?
        private var retryTimes: Int = 0
        
        enum CodingKeys: String, CodingKey {
            case id
            case createTime
            case status
            case type
            case data
            case internalStatus
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
        }
        
        func stopTimer() {
            if let timer = timer {
                timer.invalidate()
                self.timer = nil
            }
        }
        
        @objc private func onCheck() {
            Task {
                do {
                    let result = try await FlowNetwork.getTransactionResult(by: id.hex)
                    DispatchQueue.main.async {
                        if result.status == self.status {
                            self.startTimer()
                            return
                        }
                        
                        self.status = result.status
                        if result.isFailed {
                            self.internalStatus = .failed
                        } else if result.isComplete {
                            self.internalStatus = .success
                        } else {
                            self.internalStatus = .pending
                            self.startTimer()
                        }
                        
                        self.postNotification()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.retryTimes += 1
                        self.startTimer()
                    }
                }
            }
        }
        
        private func postNotification() {
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
        
        removeTransaction(id: holder.id.hex)
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
    }
    
    func removeTransaction(id: String) {
        holders.removeAll { $0.id.hex == id }
        saveHoldersToCache()
        postDidChangedNotification()
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
