//
//  PuthNotificationManager.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/24.
//

import Foundation
import UserNotifications

enum PushNotificationManagerError: Error {
    case errorInRequestingAuthorization
    case errorInSchedulingNotification
}

final class PushNotificationManager {
    static let shared = PushNotificationManager()
    private init() {}
}

extension PushNotificationManager {
    /// ユーザにプッシュ通知の許可をとる
    ///
    /// - throws: PushNotificationManagerError
    ///
    /// ```
    /// # PushNotificationManagerError
    /// - errorInRequestingAuthorization
    /// ```
    func requestAuthorization() async throws {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            print(error)
            throw PushNotificationManagerError.errorInRequestingAuthorization
        }
    }
    
    func setupPushNotifications() async throws {
        for value in NotificationValue.allCases {
            try await scheduleNotification(notificationValue: value)
        }
    }
    
    func cancelAllScheduledPushNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    /// プッシュ設定をデバイスに適用する
    ///
    /// - throws: PushNotificationManagerError
    ///
    /// ```
    /// # PushNotificationManagerError
    /// - errorInSchedulingNotification
    /// ```
    func applyPushNotificaionSettings(userSettings: UserSettings) async throws {
        var pushIds: [String] = []
        
        if userSettings.pushMorningEnabled {
            try await scheduleNotification(notificationValue: .morning)
        } else {
            pushIds.append(NotificationValue.morning.rawValue)
        }
        
        if userSettings.pushAfternoonEnabled {
            try await scheduleNotification(notificationValue: .afternoon)
        } else {
            pushIds.append(NotificationValue.afternoon.rawValue)
        }
        
        if userSettings.pushEveningEnabled {
            try await scheduleNotification(notificationValue: .evening)
        } else {
            pushIds.append(NotificationValue.evening.rawValue)
        }
        
        if !pushIds.isEmpty {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: pushIds)
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: pushIds)
        }
    }
    
    private func scheduleNotification(notificationValue: NotificationValue) async throws {
        let content = UNMutableNotificationContent()
        content.title = notificationValue.title
        content.subtitle = notificationValue.subtitle
        content.sound = .default
        content.badge = 1
        
        let calendar: Calendar = Calendar.current
        var date = DateComponents()
        date.calendar = calendar
        date.hour = notificationValue.hour
        date.minute = notificationValue.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: notificationValue.rawValue,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print(error)
            throw PushNotificationManagerError.errorInSchedulingNotification
        }
    }
}

extension PushNotificationManager {
    enum NotificationValue: String, CaseIterable {
        case morning
        case afternoon
        case evening
        
        var title: String {
            switch self {
            case .morning:
                return "お知らせ"
            case .afternoon:
                return "お知らせ"
            case .evening:
                return "お知らせ"
            }
        }
        
        var subtitle: String {
            switch self {
            case .morning:
                return "今朝の最新ニュースをチェック"
            case .afternoon:
                return "お昼の最新ニュースをチェック"
            case .evening:
                return "夕方の最新ニュースをチェック"
            }
        }
        
        var hour: Int {
            switch self {
            case .morning:
                return 8
            case .afternoon:
                return 12
            case .evening:
                return 17
            }
        }
        
        var minute: Int {
            switch self {
            case .morning:
                return 0
            case .afternoon:
                return 0
            case .evening:
                return 0
            }
        }
        
//        var hour: Int {
//            switch self {
//            case .morning, .afternoon, .evening:
//                return 11
//            }
//        }
//        
//        var minute: Int {
//            let min: Int = 57
//            switch self {
//            case .morning:
//                return min
//            case .afternoon:
//                return min + 1
//            case .evening:
//                return min + 2
//            }
//        }
    }
}
