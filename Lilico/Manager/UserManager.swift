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
    @Published
    var isLoggedIn = false

    var handle: AuthStateDidChangeListenerHandle?

//    init() {
//        listenAuthenticationState()
//    }

    func listenAuthenticationState() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print(user)
                self!.isLoggedIn = true
            } else {
                self!.isLoggedIn = false
            }
        }
    }

    func login() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            print("Logged in -> \(result.user.uid)")
        } catch {
            debugPrint(error.localizedDescription)
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

    deinit {
        print("deinit - seession store")
    }
}
