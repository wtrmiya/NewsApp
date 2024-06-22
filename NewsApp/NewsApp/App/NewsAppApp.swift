//
//  NewsAppApp.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

@main
struct NewsAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appDependencyContainer: AppDependencyContainer = AppDependencyContainer()
    @StateObject private var toastHandler: ToastHandler = ToastHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDependencyContainer)
                .displayToast(handledBy: toastHandler)
        }
    }
}
