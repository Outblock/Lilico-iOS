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
        case root(String?)
        case username(String?)
        case tynk(String, String?)
    }
}

extension RouteMap.Register: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root(let mnemonic):
            navi.push(content: TermsAndPolicy(mnemonic: mnemonic))
        case .username(let mnemonic):
            navi.push(content: UsernameView(mnemonic: mnemonic))
        case .tynk(let username, let mnemonic):
            navi.push(content: TYNKView(username: username, mnemonic: mnemonic))
        }
    }
}

// MARK: - Backup

extension RouteMap {
    enum Backup {
        case rootWithMnemonic
        case backupToCloud(BackupManager.BackupType)
        case backupManual
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
        case .backupManual:
            navi.push(content: ManualBackupView())
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

// MARK: - Profile

extension RouteMap {
    enum Profile {
        case themeChange
        case developer
        case addressBook
        case edit
        case editName
        case editAvatar([EditAvatarView.AvatarItemModel])
        case backupChange
    }
}

extension RouteMap.Profile: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .themeChange:
            navi.push(content: ThemeChangeView())
        case .developer:
            navi.push(content: DeveloperModeView())
        case .addressBook:
            navi.push(content: AddressBookView())
        case .edit:
            navi.push(content: ProfileEditView())
        case .editName:
            navi.push(content: ProfileEditNameView())
        case .editAvatar(let items):
            navi.push(content: EditAvatarView(items: items))
        case .backupChange:
            if let existVC = navi.viewControllers.first { $0.navigationItem.title == "backup".localized } {
                navi.popToViewController(existVC, animated: true)
                return
            }
            
            navi.push(content: ProfileBackupView())
        }
    }
}

// MARK: - AddressBook

extension RouteMap {
    enum AddressBook {
        case root
        case add(AddressBookView.AddressBookViewModel)
        case edit(Contact, AddressBookView.AddressBookViewModel)
    }
}

extension RouteMap.AddressBook: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: AddressBookView())
        case .add(let vm):
            navi.push(content: AddAddressView(addressBookVM: vm))
        case .edit(let contact, let vm):
            navi.push(content: AddAddressView(editingContact: contact, addressBookVM: vm))
        }
    }
}

// MARK: - PinCode

extension RouteMap {
    enum PinCode {
        case root
        case pinCode
        case confirmPinCode(String)
    }
}

extension RouteMap.PinCode: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RequestSecureView())
        case .pinCode:
            navi.push(content: CreatePinCodeView())
        case .confirmPinCode(let lastPin):
            navi.push(content: ConfirmPinCodeView(lastPin: lastPin))
        }
    }
}

// MARK: - NFT

extension RouteMap {
    enum NFT {
        case detail(NFTTabViewModel, NFTModel)
        case collection(NFTTabViewModel, CollectionItem)
        case addCollection(NFTTabViewModel)
    }
}

extension RouteMap.NFT: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let vm, let nft):
            navi.push(content: NFTDetailPage(viewModel: vm, nft: nft))
        case .collection(let vm, let collection):
            navi.push(content: NFTCollectionListView(viewModel: vm, collection: collection))
        case .addCollection(let vm):
            navi.push(content: NFTAddCollectionView(viewModel: vm))
        }
    }
}
