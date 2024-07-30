//
//  APIKeyManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

enum APIKeyManagerError: Error {
    case specifiedKeyDoesNotExist
    case specifiedServiceDoesNotExist
}

final class APIKeyManager {
    static let shared = APIKeyManager()
    private init() {}
    
    func apiKey(for service: String) throws -> String {
        guard let keys = Bundle.main.infoDictionary?["ApiKeys"] as? [String: Any]
        else {
            throw APIKeyManagerError.specifiedKeyDoesNotExist
        }
        
        guard let key = keys[service] as? String
        else {
            throw APIKeyManagerError.specifiedServiceDoesNotExist
        }
        
        return key
    }
}
