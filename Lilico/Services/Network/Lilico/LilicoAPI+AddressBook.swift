//
//  LilicoAPI+AddressBook.swift
//  Lilico
//
//  Created by Hao Fu on 19/5/2022.
//

import Foundation
import Moya

extension LilicoAPI {
    enum AddressBook {
        case addExternal(AddressBookAddRequest)
        case fetchList
        case delete(Int)
    }
}

extension LilicoAPI.AddressBook: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        .init(string: "https://dev.lilico.app/v1")!
    }
    
    var path: String {
        switch self {
        case .addExternal:
            return "/addressbook/external"
        case .fetchList, .delete:
            return "/addressbook/contact"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .addExternal:
            return .put
        case .fetchList:
            return .get
        case .delete:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .fetchList:
            return .requestPlain
        case let .addExternal(request):
            return .requestCustomJSONEncodable(request, encoder: LilicoAPI.jsonEncoder)
        case let .delete(contactId):
            return .requestParameters(parameters: ["id": contactId], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        nil
    }
}
