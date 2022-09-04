//
//  ProfileBackupViewModel.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI
import Combine

class WalletConnectViewModel: ObservableObject {
    @Published var selectedBackupType: BackupManager.BackupType = LocalUserDefaults.shared.backupType
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        
    }
    
    func changeBackupTypeAction(_ type: BackupManager.BackupType) {
        
    }
}
