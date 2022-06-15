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
    
    @Published var isLoggedIn: Bool = false {
        didSet {
            debugPrint("UserManager -> isLoggedIn: \(isLoggedIn)")
        }
    }
    @Published var isAnonymous: Bool = true

    init() {
        refreshFlags()
        uploadUserNameIfNeeded()
        loginAnonymousIfNeeded()
        
        if isLoggedIn {
            Task {
                try? await fetchUserInfo()
            }
        }
    }
}

// MARK: - Register

extension UserManager {
    func register(_ username: String) async throws {
        guard let mnemonicModel = WalletManager.shared.createMnemonicModel() else {
            HUD.error(title: "empty_wallet_key".localized)
            throw LLError.emptyWallet
        }
        
        let key = mnemonicModel.flowAccountKey
        let request = RegisterRequest(username: username, accountKey: key.toCodableModel())
        let model: RegisterResponse = try await Network.request(LilicoAPI.User.register(request))
        
        try await finishLogin(mnemonic: mnemonicModel.mnemonic, customToken: model.customToken)
        WalletManager.shared.asyncCreateWalletAddressFromServer()
    }
}

// MARK: - Restore Login

extension UserManager {
    func restoreLogin(withMnemonic mnemonic: String) async throws {
        guard let mnemonicModel = WalletManager.shared.createMnemonicModel(mnemonic: mnemonic) else {
            throw LLError.incorrectPhrase
        }
        
        guard let uid = getUid(), !uid.isEmpty else {
            loginAnonymousIfNeeded()
            throw LLError.restoreLoginFailed
        }
        
        let publicKey = mnemonicModel.getPublicKey()
        guard let signature = mnemonicModel.sign(uid) else {
            throw LLError.restoreLoginFailed
        }
        
        let request = LoginRequest(publicKey: publicKey, signature: signature)
        let response: Network.Response<LoginResponse> = try await Network.requestWithRawModel(LilicoAPI.User.login(request))
        if response.httpCode == 404 {
            throw LLError.accountNotFound
        }
        
        guard let customToken = response.data?.customToken, !customToken.isEmpty else {
            throw LLError.restoreLoginFailed
        }
        
        try await finishLogin(mnemonic: mnemonicModel.mnemonic, customToken: customToken)
    }
}

// MARK: - Internal Login Logic

extension UserManager {
    private func finishLogin(mnemonic: String, customToken: String) async throws {
        try await firebaseLogin(customToken: customToken)
        try await fetchUserInfo()
        uploadUserNameIfNeeded()
        
        guard let username = userInfo?.username else {
            throw LLError.fetchUserInfoFailed
        }
        
        try WalletManager.shared.storeAndActiveMnemonicToKeychain(mnemonic, username: username)
    }
    
    private func firebaseLogin(customToken: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: customToken)
        debugPrint("Logged in -> \(result.user.uid)")
    }
    
    private func fetchUserInfo() async throws {
        let response: UserInfoResponse = try await Network.request(LilicoAPI.User.userInfo)
        let info = UserInfo(avatar: response.avatar, nickname: response.nickname, username: response.username, private: response.private)
        
        if info.username.isEmpty {
            throw LLError.fetchUserInfoFailed
        }
        
        DispatchQueue.main.async {
            LocalUserDefaults.shared.userInfo = info
            self.userInfo = info
        }
    }
}

// MARK: - Internal

extension UserManager {
    private func refreshFlags() {
        isLoggedIn = userInfo != nil
        isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
    }
    
    private func loginAnonymousIfNeeded() {
        if isLoggedIn {
            return
        }
        
        if Auth.auth().currentUser == nil {
            Task {
                do {
                    try await Auth.auth().signInAnonymously()
                    DispatchQueue.main.async {
                        self.refreshFlags()
                    }
                } catch {
                    debugPrint("signInAnonymously failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
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
    
    private func uploadUserName(username: String) async {
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
    
    func updateNickname(_ name: String) {
        guard let current = userInfo else {
            return
        }
        
        let newUserInfo = UserInfo(avatar: current.avatar, nickname: name, username: current.username, private: current.private)
        LocalUserDefaults.shared.userInfo = newUserInfo
        userInfo = newUserInfo
    }
    
    func updatePrivate(_ isPrivate: Bool) {
        guard let current = userInfo else {
            return
        }
        
        let newUserInfo = UserInfo(avatar: current.avatar, nickname: current.nickname, username: current.username, private: isPrivate ? 2 : 1)
        LocalUserDefaults.shared.userInfo = newUserInfo
        userInfo = newUserInfo
    }
}
