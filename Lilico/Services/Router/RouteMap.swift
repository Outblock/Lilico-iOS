//
//  RouterMap.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import SwiftUIX

enum RouteMap {
    
}

// MARK: - Restore Login

extension RouteMap {
    enum RestoreLogin {
        case root
        case restoreManual
        case chooseAccount([BackupManager.DriveItem])
        case enterRestorePwd(BackupManager.DriveItem)
    }
}

extension RouteMap.RestoreLogin: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RestoreWalletView())
        case .restoreManual:
            navi.push(content: InputMnemonicView())
        case .chooseAccount(let items):
            navi.push(content: ChooseAccountView(driveItems: items))
        case .enterRestorePwd(let item):
            navi.push(content: EnterRestorePasswordView(driveItem: item))
        }
    }
}

// MARK: - Register

extension RouteMap {
    enum Register {
        case root
        case username
        case tynk(String)
    }
}

extension RouteMap.Register: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: TermsAndPolicy())
        case .username:
            navi.push(content: UsernameView())
        case .tynk(let username):
            navi.push(content: TYNKView(username: username))
        }
    }
}

// MARK: - Backup

extension RouteMap {
    enum Backup {
        case rootWithMnemonic
        case backupToCloud(BackupManager.BackupType)
    }
}

extension RouteMap.Backup: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .rootWithMnemonic:
            guard let rootVC = navi.viewControllers.first else {
                return
            }
            
            var newVCList = [rootVC]
            let vc = RouteableUIHostingController(rootView: RecoveryPhraseView())
            newVCList.append(vc)
            navi.setViewControllers(newVCList, animated: true)
        case .backupToCloud(let type):
            navi.push(content: BackupPasswordView(backupType: type))
        }
    }
}

// MARK: - Wallet

extension RouteMap {
    enum Wallet {
        case addToken
        case tokenDetail(TokenModel)
        case receive
        case send
        case sendAmount(Contact)
    }
}

extension RouteMap.Wallet: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .addToken:
            navi.push(content: AddTokenView())
        case .tokenDetail(let token):
            navi.push(content: TokenDetailView(token: token))
        case .receive:
            navi.present(content: WalletReceiveView())
        case .send:
            navi.present(content: WalletSendView())
        case .sendAmount(let contact):
            navi.push(content: WalletSendAmountView(target: contact))
        }
    }
}

extension RouteMap {
    enum Profile {
        case themeChange
        case developer
    }
}

extension RouteMap.Profile: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .themeChange:
            navi.push(content: ThemeChangeView())
        case .developer:
            navi.push(content: DeveloperModeView())
        }
    }
}
