//
//  RouterMap.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import SwiftUIX
import Flow

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
            let vc = RouteableUIHostingController(rootView: RecoveryPhraseView(backupMode: false))
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
        case sendAmount(Contact, TokenModel)
        case scan((SPQRCodeData, SPQRCameraController)->Void)
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
        case .sendAmount(let contact, let token):
            navi.push(content: WalletSendAmountView(target: contact, token: token))
        case .scan(let handler):
//            let rootVC = Router.topPresentedController()
            SPQRCode.scanning(handled: handler, on: navi)
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
        case editAvatar
        case backupChange
        case manualBackup
        case security(Bool)
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
        case .editAvatar:
            navi.push(content: EditAvatarView())
        case .backupChange:
            if let existVC = navi.viewControllers.first(where: { $0.navigationItem.title == "backup".localized }) {
                navi.popToViewController(existVC, animated: true)
                return
            }
            
            navi.push(content: ProfileBackupView())
        case .manualBackup:
            navi.push(content: RecoveryPhraseView(backupMode: true))
        case .security(let animated):
            if let existVC = Router.coordinator.rootNavi?.viewControllers.first(where: { $0.navigationItem.title == "security".localized }) {
                navi.popToViewController(existVC, animated: animated)
                return
            }
            
            Router.coordinator.rootNavi?.push(content: ProfileSecureView(), animated: animated)
        }
    }
}

// MARK: - AddressBook

extension RouteMap {
    enum AddressBook {
        case root
        case add(AddressBookView.AddressBookViewModel)
        case edit(Contact, AddressBookView.AddressBookViewModel)
        case pick(WalletSendView.WalletSendViewSelectTargetCallback)
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
        case .pick(let callback):
            navi.present(content: WalletSendView(callback: callback))
        }
    }
}

// MARK: - PinCode

extension RouteMap {
    enum PinCode {
        case root
        case pinCode
        case confirmPinCode(String)
        case verify(Bool, Bool, VerifyPinViewModel.VerifyCallback)
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
        case .verify(let animated, let needNavi, let callback):
            let vc = RouteableUIHostingController(rootView: VerifyPinView(callback: callback))
            vc.modalPresentationStyle = .fullScreen
            if needNavi {
                let contentNavi = RouterNavigationController(rootViewController: vc)
                contentNavi.modalPresentationCapturesStatusBarAppearance = true
                contentNavi.modalPresentationStyle = .fullScreen
                Router.topPresentedController().present(contentNavi, animated: animated)
            } else {
                Router.topPresentedController().present(vc, animated: animated)
            }
        }
    }
}

// MARK: - NFT

extension RouteMap {
    enum NFT {
        case detail(NFTTabViewModel, NFTModel)
        case collection(NFTTabViewModel, CollectionItem)
        case addCollection
        case send(NFTModel, Contact)
    }
}

extension RouteMap.NFT: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let vm, let nft):
            navi.push(content: NFTDetailPage(viewModel: vm, nft: nft))
        case .collection(let vm, let collection):
            navi.push(content: NFTCollectionListView(viewModel: vm, collection: collection))
        case .addCollection:
            navi.push(content: NFTAddCollectionView())
        case .send(let nft, let contact):
            let vc = CustomHostingController(rootView: NFTTransferView(nft: nft, target: contact))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - WalletConnect

extension RouteMap {
    enum WalletConnect {
        case approve(SessionInfo, () -> (), () -> ())
        case request(RequestInfo, () -> (), () -> ())
        case requestMessage(RequestMessageInfo, () -> (), () -> ())
    }
}

extension RouteMap.WalletConnect: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .approve(let info, let approve, let reject):
            Router.topPresentedController().present(content: ApproveView(session: info, approve: approve, reject: reject))
        case .request(let info, let approve, let reject):
            Router.topPresentedController().present(content: RequestView(request: info, approve: approve, reject: reject))
        case .requestMessage(let info, let approve, let reject):
            Router.topPresentedController().present(content: RequestMessageView(request: info, approve: approve, reject: reject))
        }
    }
}

// MARK: - Transaction

extension RouteMap {
    enum Transaction {
        case detail(Flow.ID)
    }
}

extension RouteMap.Transaction: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let transactionId):
            if let url = transactionId.transactionFlowScanURL {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Explore

extension RouteMap {
    enum Explore {
        case browser
    }
}

extension RouteMap.Explore: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .browser:
            let vc = BrowserViewController()
            navi.pushViewController(vc, animated: true)
        }
    }
}
