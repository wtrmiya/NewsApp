//
//  TermManagerProtocol.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation

protocol TermManagerProtocol {
    func getLatestTerm() async throws -> Term
}
