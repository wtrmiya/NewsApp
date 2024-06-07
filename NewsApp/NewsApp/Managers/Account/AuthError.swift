//
//  AuthError.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/07.
//

import Foundation

enum AuthError: Error {
    case authError(errorMessage: String)
    case unknownError(errorMessage: String)
}
