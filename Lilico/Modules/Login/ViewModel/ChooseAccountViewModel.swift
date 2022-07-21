//
//  ChooseAccountViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 9/1/22.
//

import SwiftUI
import Stinsen

class ChooseAccountViewModel: ObservableObject {
    @Published var items: [BackupManager.DriveItem] = []
    @RouterObject var router: LoginCoordinator.Router?
    
    init(driveItems: [BackupManager.DriveItem]) {
        items = driveItems
    }
    
    func restoreAccountAction(item: BackupManager.DriveItem) {
        router?.route(to: \.enterRestorePwd, item)
    }
}
