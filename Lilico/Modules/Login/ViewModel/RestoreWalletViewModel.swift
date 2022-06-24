//
//  RestoreWalletViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 1/1/22.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore
import Stinsen

class RestoreWalletViewModel {
    @RouterObject
    var router: LoginCoordinator.Router?

    func getKeyFromiCloud() {
        if let accountList = BackupManager.shared.loadAccountDataFromiCloud(), accountList.count > 0 {
            router?.route(to: \.chooseAccount, accountList)
        } else {
            HUD.error(title: "no_icloud_backup".localized)
        }
    }

    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if error != nil || user == nil {
                print("ERRRR: \(String(describing: error)), \(String(describing: error?.localizedDescription))")
//                self?.updateScreen()
            } else {
                // Post notification after user successfully sign in
                guard let user = user else { return }
                print("restore signIn state")
//                self?.createGoogleDriveService(user: user)
            }
        }
    }

    func signInButtonTapped() {
        // 1
        guard let topVC = UIApplication.shared.topMostViewController else {
            return
        }
        let signInConfig = GIDConfiguration(clientID: "246247206636-srqmvc5l0fievp3ui5oshvsaml5a9pnb.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: topVC) { [weak self] user, error in

            guard let self = self else { return }

            if let error = error {
                print("SignIn failed, \(error), \(error.localizedDescription)")
            } else {
                print("Authenticate successfully")

                let driveScope = kGTLRAuthScopeDriveAppdata
                guard let user = user else { return }

                let grantedScopes = user.grantedScopes
                print("scopes: \(String(describing: grantedScopes))")

                // 2
                if grantedScopes == nil || !grantedScopes!.contains(driveScope) {
                    GIDSignIn.sharedInstance.addScopes([driveScope], presenting: topVC) { [weak self] user, error in

                        if let error = error {
                            print("add scope failed, \(error), \(error.localizedDescription)")
                        }

                        guard let user = user else { return }

                        DispatchQueue.main.async {
                            print("userDidSignInGoogle")
//                           self?.updateScreen()
                        }

                        // Check if the user granted access to the scopes you requested.
                        if let scopes = user.grantedScopes,
                           scopes.contains(driveScope)
                        {
                            print("Scope added")
                            // 3
                            self?.createGoogleDriveService(user: user)
                        }
                    }
                }
            }
        }
    }

    func createGoogleDriveService(user: GIDGoogleUser) {
        let metadata = GTLRDrive_File()
        metadata.name = "Lilico_app_backup_v1"

        // 1. set service type to GoogleDrive
        let service = GTLRDriveService()
        service.authorizer = user.authentication.fetcherAuthorizer()
        // dependency inject
//        stateManager.googleAPIs = GoogleDriveAPI(service: service)

        // 2. To ensure that your Google API calls always have a new authorizer
        user.authentication.do { [weak self] authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication else { return }

            // get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let service = GTLRDriveService()
            service.authorizer = authentication.fetcherAuthorizer()

            // 3. dependency inject
//            self?.stateManager.googleAPIs = GoogleDriveAPI(service: service)
//
//            // 4. open GoogleDriveViewController page when authentication is complete
//            let vc = GoogleDriveViewController()
//            vc.stateManager = self?.stateManager
//            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func uploadFile(service: GTLRDriveService, name: String,
                    data: Data, mimeType: String = "application/vnd.google-apps.document")
    {
        let file = GTLRDrive_File()
        file.name = name
//        file.parents = [folderID]

        let uploadParameters = GTLRUploadParameters(data: data, mimeType: mimeType)
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)

        service.uploadProgressBlock = { _, _, _ in
            // This block is called multiple times during upload and can
            // be used to update a progress indicator visible to the user.
        }

        service.executeQuery(query) { _, _, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
    }
}
