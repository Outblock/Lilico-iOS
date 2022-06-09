//
//  UserManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Firebase
import FirebaseAuth
import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()

    @Published var userInfo: UserInfo? = LocalUserDefaults.shared.userInfo {
        didSet {
            refreshFlags()
            uploadUserNameIfNeeded()
        }
    }
    
    @Published var isLoggedIn: Bool = false
    @Published var isAnonymous: Bool = true

    init() {
        refreshFlags()
        uploadUserNameIfNeeded()
    }
    
    private func refreshFlags() {
        isLoggedIn = userInfo != nil
        isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
    }
}

// MARK: - Register

extension UserManager {
    func register(_ username: String) async throws {
        guard let mnemonicModel = WalletManager.shared.createMnemonicModel() else {
            HUD.error(title: "Empty Wallet Key")
            throw LLError.emptyWallet
        }
        
        let key = mnemonicModel.flowAccountKey
        let request = RegisterRequest(username: username, accountKey: key.toCodableModel())
        let model: RegisterResponse = try await Network.request(LilicoAPI.User.register(request))
        
        try await loginWithCustomToken(model.customToken)
        uploadUserNameIfNeeded()
        try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonicModel.mnemonic, username: username)
        WalletManager.shared.asyncCreateWalletAddressFromServer()
    }
}

// MARK: - Login

extension UserManager {
    func loginWithCustomToken(_ token: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: token)
        debugPrint("Logged in -> \(result.user.uid)")
        try await fetchUserInfo()
    }
    
    func fetchUserInfo() async throws {
        let response: UserInfoResponse = try await Network.request(LilicoAPI.User.userInfo)
        let info = UserInfo(avatar: response.avatar, nickname: response.nickname, username: response.username, private: response.private)
        LocalUserDefaults.shared.userInfo = info
        userInfo = info
    }
}

// MARK: - Restore

extension UserManager {
    
}

// MARK: - Modify

extension UserManager {
    private func uploadUserNameIfNeeded() {
        if isAnonymous || !isLoggedIn {
            return
        }
        
        let username = userInfo?.username ?? ""
        let displayName = Auth.auth().currentUser?.displayName ?? ""
        
        if !username.isEmpty, username != displayName {
            Task {
                await uploadUserName(username: username)
            }
        }
    }
    
    func uploadUserName(username: String) async {
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
            return
        }
        
        changeRequest.displayName = username
        do {
            try await changeRequest.commitChanges()
        } catch {
            debugPrint("update displayName failed")
        }
    }
}
