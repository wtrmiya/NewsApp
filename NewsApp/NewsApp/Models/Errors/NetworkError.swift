//
//  NetworkError.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/12.
//

import Foundation

enum NetworkError: String, Error {
    case invalidResponse
    case invalidData
    case failedInJSONSerialization
    case invalidAPIKey
}
