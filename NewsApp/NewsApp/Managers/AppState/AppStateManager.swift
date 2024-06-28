//
//  AppStateManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/27.
//

import Foundation

enum AppState {
    case launching
    case launched
}

final class AppStateManager {
    static let shared = AppStateManager()
    private init() {}
    
    var appState: AppState = .launching {
        didSet {
            print("appState: \(appState)")
        }
    }
}
