//
//  BackupGDTarget.swift
//  Lilico
//
//  Created by Selina on 18/7/2022.
//

import UIKit
import SwiftUI
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore

private let ClientID = "246247206636-srqmvc5l0fievp3ui5oshvsaml5a9pnb.apps.googleusercontent.com"

class BackupGDTarget: BackupTarget {
    private let config = GIDConfiguration(clientID: ClientID)
    private var api: GoogleDriveAPI?
    
    var isPrepared: Bool {
        return api != nil
    }
}

extension BackupGDTarget {
    func uploadMnemonic(password: String) throws {
//        let list = try BackupManager.shared.addCurrentMnemonicToList(getCurrentDriveItems(), password: password)
//        let encrypedString = try BackupManager.shared.encryptList(list)
    }
    
    func getCurrentDriveItems() async throws -> [BackupManager.DriveItem] {
        return []
    }
    
    func testGetFileId() async throws -> String? {
        try await prepare()
        return try await api?.getFileId(fileName: BackupManager.backupFileName)
    }
}

extension BackupGDTarget {
    private func prepare() async throws {
        if isPrepared {
            return
        }
        
        var user = try await googleUserLogin()
        user = try await addScopesIfNeeded(user: user)
        createGoogleDriveService(user: user)
    }
    
    private func googleUserLogin() async throws -> GIDGoogleUser {
        guard let topVC = await UIApplication.shared.topMostViewController else {
            throw BackupError.topVCNotFound
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.signIn(with: self.config, presenting: topVC) { user, error in
                    guard let signInUser = user else {
                        continuation.resume(throwing: error ?? GoogleBackupError.missingLoginUser)
                        return
                    }
                    
                    continuation.resume(returning: signInUser)
                }
            }
        }
    }
    
    private func addScopesIfNeeded(user: GIDGoogleUser) async throws -> GIDGoogleUser {
        guard let topVC = await UIApplication.shared.topMostViewController else {
            throw BackupError.topVCNotFound
        }
        
        let driveScope = kGTLRAuthScopeDriveAppdata
        if let grantedScopes = user.grantedScopes, grantedScopes.contains(driveScope) {
            return user
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                GIDSignIn.sharedInstance.addScopes([driveScope], presenting: topVC) { grantedUser, error in
                    guard let grantedUser = grantedUser else {
                        continuation.resume(throwing: error ?? GoogleBackupError.missingLoginUser)
                        return
                    }
                    
                    guard let scopes = grantedUser.grantedScopes, scopes.contains(driveScope) else {
                        continuation.resume(throwing: GoogleBackupError.noDriveScope)
                        return
                    }
                    
                    continuation.resume(returning: grantedUser)
                }
            }
        }
    }
    
    private func createGoogleDriveService(user: GIDGoogleUser) {
        let service = GTLRDriveService()
        service.authorizer = user.authentication.fetcherAuthorizer()
        
        api = GoogleDriveAPI(user: user, service: service)
        
        user.authentication.do { [weak self] authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication else { return }
            
            let authorizer = authentication.fetcherAuthorizer()
            let service = GTLRDriveService()
            service.authorizer = authorizer
            self?.api = GoogleDriveAPI(user: user, service: service)
        }
    }
}
