//
//  UserSettings.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/14.
//

import Foundation
import FirebaseFirestore

struct UserSettings {
    let uid: String
    let pushMorningEnabled: Bool
    let pushAfternoonEnabled: Bool
    let pushEveningEnabled: Bool
    let createdAt: Date
    let updatedAt: Date
}

extension UserSettings {
    static func defaultSettings(uid: String) -> UserSettings {
        return UserSettings(
            uid: uid,
            pushMorningEnabled: true,
            pushAfternoonEnabled: true,
            pushEveningEnabled: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "push_morning_enabled": pushMorningEnabled,
            "push_afternoon_enabled": pushAfternoonEnabled,
            "push_evening_enabled": pushEveningEnabled,
            "created_at": createdAt,
            "updated_at": updatedAt
        ]
    }
    
    static func fromSnapshot(snapshot: QueryDocumentSnapshot) -> UserSettings? {
        let dictionary = snapshot.data()
        guard
            let uid = dictionary["uid"] as? String,
            let pushMorningEnabled = dictionary["push_morning_enabled"] as? Bool,
            let pushAfternoonEnabled = dictionary["push_afternoon_enabled"] as? Bool,
            let pushEveningEnabled = dictionary["push_evening_enabled"] as? Bool,
            let createdAt = (dictionary["created_at"] as? Timestamp)?.dateValue(),
            let updatedAt = (dictionary["updated_at"] as? Timestamp)?.dateValue()
        else {
            return nil
        }

        return UserSettings(
            uid: uid,
            pushMorningEnabled: pushMorningEnabled,
            pushAfternoonEnabled: pushAfternoonEnabled,
            pushEveningEnabled: pushEveningEnabled,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
