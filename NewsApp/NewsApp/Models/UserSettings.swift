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
    var pushMorningEnabled: Bool
    var pushAfternoonEnabled: Bool
    var pushEveningEnabled: Bool
    var letterSize: Int
    var letterWeight: Int
    var darkMode: Int
    let createdAt: Date
    var updatedAt: Date
    var documentId: String?
}

extension UserSettings {
    mutating func setDocumentId(documentId: String) {
        self.documentId = documentId
    }
    
    static func defaultSettings(uid: String) -> UserSettings {
        return UserSettings(
            uid: uid,
            pushMorningEnabled: true,
            pushAfternoonEnabled: true,
            pushEveningEnabled: true,
            letterSize: 1,
            letterWeight: 0,
            darkMode: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    static func defaultSettingsWithDummyUID() -> UserSettings {
        return UserSettings(
            uid: UUID().uuidString,
            pushMorningEnabled: true,
            pushAfternoonEnabled: true,
            pushEveningEnabled: true,
            letterSize: 1,
            letterWeight: 0,
            darkMode: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    var pushSettingsDescription: String {
        if !pushMorningEnabled && !pushAfternoonEnabled && !pushEveningEnabled {
            return "許可しない"
        } else {
            return "許可する"
        }
    }
    
    var letterSettingsDescription: String {
        return "\(letterSizeSettingsDescription)/\(letterWeightSettingsDescription)"
    }
    
    private var letterSizeSettingsDescription: String {
        switch letterSize {
        case 0:
            "小"
        case 1:
            "通常"
        case 2:
            "大"
        default:
            "通常"
        }
    }
    
    private var letterWeightSettingsDescription: String {
        switch letterWeight {
        case 0:
            "通常"
        case 1:
            "太い"
        default:
            "通常"
        }
    }
    
    var darkModeDescription: String {
        switch darkMode {
        case 0:
            "端末の設定に合わせる"
        case 1:
            "常にライトモード"
        case 2:
            "常にダークモード"
        default:
            "端末の設定に合わせる"
        }
    }

    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "push_morning_enabled": pushMorningEnabled,
            "push_afternoon_enabled": pushAfternoonEnabled,
            "push_evening_enabled": pushEveningEnabled,
            "letter_size": letterSize,
            "letter_weight": letterWeight,
            "dark_mode": darkMode,
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
            let letterSize = dictionary["letter_size"] as? Int,
            let letterWeight = dictionary["letter_weight"] as? Int,
            let darkMode = dictionary["dark_mode"] as? Int,
            let createdAt = (dictionary["created_at"] as? Timestamp)?.dateValue(),
            let updatedAt = (dictionary["updated_at"] as? Timestamp)?.dateValue()
        else {
            return nil
        }
        
        let documentId = snapshot.documentID

        return UserSettings(
            uid: uid,
            pushMorningEnabled: pushMorningEnabled,
            pushAfternoonEnabled: pushAfternoonEnabled,
            pushEveningEnabled: pushEveningEnabled,
            letterSize: letterSize,
            letterWeight: letterWeight,
            darkMode: darkMode,
            createdAt: createdAt,
            updatedAt: updatedAt,
            documentId: documentId
        )
    }
}
