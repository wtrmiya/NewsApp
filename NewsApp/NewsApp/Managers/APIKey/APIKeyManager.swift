//
//  APIKeyManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/11.
//

import Foundation

final class APIKeyManager {
    static let shared = APIKeyManager()
    private init() {}
    
    func apiKey(for service: String) -> String? {
        guard let keys = Bundle.main.infoDictionary?["ApiKeys"] as? [String: Any],
              let key = keys[service] as? String
        else {
            return nil
        }
        
        return key
    }
}
