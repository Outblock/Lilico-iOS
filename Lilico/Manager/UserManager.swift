//
//  UserManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Firebase
import FirebaseAuth
import Foundation

struct UserInfo {
    let avatar: String
    let username: String
    let address: String? = nil
}

class UserManager: ObservableObject {
    static let shared = UserManager()

    var userInfo: UserInfo?

//    @Published
//    var isLoggedIn: Bool = false
    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

//    @Published
    var isAnonymous: Bool {
        Auth.auth().currentUser?.isAnonymous ?? true
    }

    var handle: AuthStateDidChangeListenerHandle?

//    init() {
//        listenAuthenticationState()
//    }

    init() {
        if let name = Auth.auth().currentUser?.displayName {
            userInfo = UserInfo(avatar: "", username: name)
        }
    }

    func listenAuthenticationState() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                print("Sign in -> \(user.uid)")
                print("isAnonymous -> \(user.isAnonymous)")
                print(user)

//                self.isAnonymous = user.isAnonymous
//                self.isLoggedIn = true
            } else {
                print("Sign out ->")
//                self.isLoggedIn = false
//                self.isAnonymous = true
            }
        }
    }

    func login() async {
        do {
            if Auth.auth().currentUser == nil {
                let result = try await Auth.auth().signInAnonymously()
                print("Logged in -> \(result.user.uid)")
                print("isAnonymous -> \(result.user.isAnonymous)")
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func loginWithCustomToken(_ token: String) async throws {
//        do {
//            let _ = try await Auth.auth().currentUser?.delete()
        let result = try await Auth.auth().signIn(withCustomToken: token)

        print("Logged in -> \(result.user.uid)")
        await fetchUserInfo()
        await fetchWalletInfo()
    }

    func updateUserName(username: String) async throws {
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else {
            return
        }

        changeRequest.displayName = username
        try await changeRequest.commitChanges()
    }

    func register(_ username: String) async throws {
        let isSuccess = try WalletManager.shared.createNewWallet(forceCreate: true)
        guard let key = WalletManager.shared.wallet?.flowAccountKey, isSuccess else {
            HUD.error(title: "Empty Wallet Key")
            throw LLError.emptyWallet
        }
        let request = RegisterReuqest(username: username, accountKey: key.toCodableModel())
        let model: RegisterResponse = try await Network.request(LilicoEndpoint.register(request))
        try await loginWithCustomToken(model.customToken)
        try await updateUserName(username: username)
        try WalletManager.shared.storeMnemonicToKeychain(username: username)
        
        // No need wait for the create address request
        Task {
            let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoEndpoint.userAddress)
        }
    }

    func getIdToken() async -> String? {
        do {
            let result = try await Auth.auth().currentUser?.getIDTokenResult()
            return result?.token
        } catch {
            debugPrint(error.localizedDescription)
            return .none
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            print("Logged out")
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func fetchUserInfo() async {
        do {
            let response: UserInfoResponse = try await Network.request(LilicoEndpoint.userInfo)
            userInfo = UserInfo(avatar: response.avatar, username: response.username)

//            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//            changeRequest?.displayName = userInfo?.userName
//            await changeRequest?.commitChanges()
        } catch {
            // TODO:
            debugPrint(error)
        }
    }

    func fetchWalletInfo() async {
        do {
            let response: UserWalletResponse = try await Network.request(LilicoEndpoint.userWallet)
            print(response)
//            userInfo =
        } catch {
            debugPrint(error)
        }
    }

    deinit {
        print("deinit - seession store")
    }
}
