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
    var letterSize: LetterSize
    var letterWeight: LetterWeight
    var darkMode: DarkModeSetting
    let createdAt: Date
    var updatedAt: Date
    var userSettingsDocumentId: String?
}

extension UserSettings {
    mutating func setSettingsDocumentId(userSettingsDocumentId: String) {
        self.userSettingsDocumentId = userSettingsDocumentId
    }
    
    static func defaultSettings(uid: String) -> UserSettings {
        return UserSettings(
            uid: uid,
            pushMorningEnabled: true,
            pushAfternoonEnabled: true,
            pushEveningEnabled: true,
            letterSize: LetterSize.medium,
            letterWeight: LetterWeight.normal,
            darkMode: DarkModeSetting.followDeviceSetting,
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
            letterSize: LetterSize.medium,
            letterWeight: LetterWeight.normal,
            darkMode: DarkModeSetting.followDeviceSetting,
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
    
    var letterSizeSettingsDescription: String {
        switch letterSize {
        case .small:
            "小"
        case .medium:
            "中"
        case .large:
            "大"
        }
    }
    
    var letterWeightSettingsDescription: String {
        switch letterWeight {
        case .normal:
            "通常"
        case .thick:
            "太い"
        }
    }
    
    var darkModeDescription: String {
        switch darkMode {
        case .followDeviceSetting:
            "端末の設定に合わせる"
        case .lightModeAlways:
            "常にライトモード"
        case .darkModeAlways:
            "常にダークモード"
        }
    }

    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "push_morning_enabled": pushMorningEnabled,
            "push_afternoon_enabled": pushAfternoonEnabled,
            "push_evening_enabled": pushEveningEnabled,
            "letter_size": letterSize.rawValue,
            "letter_weight": letterWeight.rawValue,
            "dark_mode": darkMode.rawValue,
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
            let letterSizeRawValue = dictionary["letter_size"] as? Int,
            let letterSize = LetterSize(rawValue: letterSizeRawValue),
            let letterWeightRawValue = dictionary["letter_weight"] as? Int,
            let letterWeight = LetterWeight(rawValue: letterWeightRawValue),
            let darkModeRawValue = dictionary["dark_mode"] as? Int,
            let darkModeSetting = DarkModeSetting(rawValue: darkModeRawValue),
            let createdAt = (dictionary["created_at"] as? Timestamp)?.dateValue(),
            let updatedAt = (dictionary["updated_at"] as? Timestamp)?.dateValue()
        else {
            return nil
        }

        let userSettingsDocumentId = snapshot.documentID

        return UserSettings(
            uid: uid,
            pushMorningEnabled: pushMorningEnabled,
            pushAfternoonEnabled: pushAfternoonEnabled,
            pushEveningEnabled: pushEveningEnabled,
            letterSize: letterSize,
            letterWeight: letterWeight,
            darkMode: darkModeSetting,
            createdAt: createdAt,
            updatedAt: updatedAt,
            userSettingsDocumentId: userSettingsDocumentId
        )
    }
}
