//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    let pushNotificationManager: PushNotificationManager = PushNotificationManager.shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        Task {
            do {
                try await pushNotificationManager.requestAuthorization()
            } catch {
                print(error)
            }
        }

        return true
    }
}
