//
//  ChooseAccountViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 9/1/22.
//

import SwiftUI


class ChooseAccountViewModel: ObservableObject {
    @Published var items: [BackupManager.DriveItem] = []
    
    init(driveItems: [BackupManager.DriveItem]) {
        items = driveItems
    }
    
    func restoreAccountAction(item: BackupManager.DriveItem) {
        Router.route(to: RouteMap.RestoreLogin.enterRestorePwd(item))
    }
}
