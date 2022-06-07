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

    @Published var userInfo: UserInfo? {
        didSet {
            refreshFlags()
        }
    }
    
    @Published var isLoggedIn: Bool
    @Published var isAnonymous: Bool

    init() {
        let ui = LocalUserDefaults.shared.userInfo
        userInfo = ui
        isLoggedIn = ui != nil
        isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
    }
    
    private func refreshFlags() {
        isLoggedIn = userInfo != nil
        isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
    }
}

// MARK: - Register

extension UserManager {
    func register(_ username: String) async throws {
        let isSuccess = try WalletManager.shared.createNewWallet(forceCreate: true)
        guard let key = WalletManager.shared.wallet?.flowAccountKey, isSuccess else {
            HUD.error(title: "Empty Wallet Key")
            throw LLError.emptyWallet
        }
        let request = RegisterReuqest(username: username, accountKey: key.toCodableModel())
        let model: RegisterResponse = try await Network.request(LilicoAPI.User.register(request))
        try await loginWithCustomToken(model.customToken)
        try await updateUserName(username: username)
        try WalletManager.shared.storeMnemonicToKeychain(username: username)
        
        // No need wait for the create address request
        Task {
            let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.User.userAddress)
        }
    }
}

// MARK: - Login

extension UserManager {
    func loginWithCustomToken(_ token: String) async throws {
        let result = try await Auth.auth().signIn(withCustomToken: token)
        debugPrint("Logged in -> \(result.user.uid)")
        await fetchUserInfo()
        await fetchWalletInfo()
    }
    
    func fetchUserInfo() async {
        do {
            let response: UserInfoResponse = try await Network.request(LilicoAPI.User.userInfo)
            let info = UserInfo(avatar: response.avatar, nickname: response.nickname, username: response.username, private: response.private)
            LocalUserDefaults.shared.userInfo = info
            userInfo = info
        } catch {
            // TODO:
            debugPrint(error)
        }
    }

    func fetchWalletInfo() async {
        do {
            let response: UserWalletResponse = try await Network.request(LilicoAPI.User.userWallet)
            print(response)
        } catch {
            debugPrint(error)
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            debugPrint("Logged out")
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}

// MARK: - Modify

extension UserManager {
    func updateUserName(username: String) async throws {
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
            return
        }

        changeRequest.displayName = username
        try await changeRequest.commitChanges()
    }
}
