//
//  AppDelegate.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI
import FirebaseCore

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        Task {
            do {
                // PushNotification
                try await PushNotificationManager.shared.requestAuthorization()
                try await PushNotificationManager.shared.setupPushNotifications()
            } catch {
                print(error)
            }
        }

        return true
    }
}
