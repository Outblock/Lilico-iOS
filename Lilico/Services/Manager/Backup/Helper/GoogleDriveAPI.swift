//
//  GoogleDriveAPI.swift
//  Lilico
//
//  Created by Selina on 20/7/2022.
//

import Foundation
import GoogleAPIClientForREST_Drive
import GoogleAPIClientForRESTCore
import GoogleSignIn
import GTMSessionFetcherCore

class GoogleDriveAPI {
    private let user: GIDGoogleUser
    private let service: GTLRDriveService
    
    init(user: GIDGoogleUser, service: GTLRDriveService) {
        self.user = user
        self.service = service
    }
    
    func getFileId(fileName: String) async throws -> String? {
        let query = GTLRDriveQuery_FilesList.query()
        query.spaces = "appDataFolder"
        query.fields = "nextPageToken, files(id, name)"
        query.pageSize = 10
        
        return try await withCheckedThrowingContinuation { continuation in
            service.executeQuery(query) { ticket, results, error in
                guard let fileListObject = results as? GTLRDrive_FileList, error == nil else {
                    continuation.resume(throwing: error ?? GoogleBackupError.queryFileError)
                    return
                }
                
                guard let files = fileListObject.files else {
                    continuation.resume(returning: nil)
                    return
                }
                
                for file in files {
                    if file.name == fileName {
                        continuation.resume(returning: file.identifier)
                        return
                    }
                }
                
                continuation.resume(returning: nil)
            }
        }
    }
}
