//
//  NewsAppUserSettingsManagerIntegrationTest.swift
//  NewsAppIntegrationTests
//
//  Created by Wataru Miyakoshi on 2024/08/13.
//

import XCTest
@testable import NewsApp
import FirebaseFirestore
import FirebaseFirestoreSwift

final class NewsAppUserSettingsManagerIntegrationTest: XCTestCase {
    func test_デフォルトのユーザ設定を作成する() async {
        let collectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserSettingsManager.shared
        let userDataStoreDocRef: DocumentReference
        
        do {
            userDataStoreDocRef = try await collectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocRef.documentID)
            
            // Test
            try await sut.createDefaultUserSettings(userAccount: dummyUserAccount)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        // Check
        let fetchedUserDataStoreDocRef = collectionRef.document(userDataStoreDocRef.documentID)
        let userSettingsCollectionRef = fetchedUserDataStoreDocRef.collection("user_settings")
        do {
            guard let queryDocumentSnapshot = try await userSettingsCollectionRef.getDocuments().documents.first
            else {
                return
            }
            
            guard let fetchedUserSettings = UserSettings.fromSnapshot(snapshot: queryDocumentSnapshot)
            else {
                return
            }
            
            XCTAssertEqual(fetchedUserSettings.letterSize, .medium)
            XCTAssertEqual(fetchedUserSettings.letterWeight, .normal)
            XCTAssertEqual(fetchedUserSettings.pushMorningEnabled, true)
            XCTAssertEqual(fetchedUserSettings.pushAfternoonEnabled, true)
            XCTAssertEqual(fetchedUserSettings.pushEveningEnabled, true)
            XCTAssertEqual(fetchedUserSettings.darkMode, .followDeviceSetting)
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        do {
            // userSettings
            let userSettingsDocumentSnapshot = try await userSettingsCollectionRef.getDocuments()
            for userSettingsDocument in userSettingsDocumentSnapshot.documents {
                try await userSettingsDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await collectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
    
    func test_カレントユーザの設定を取得する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserSettingsManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
            userDataStoreDocumentId = userDataStoreDocRef.documentID
            dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
            let defaultSettingsDict = UserSettings.defaultSettings(uid: dummyUserAccount.uid).toDictionary()
            
            let _ = try await userDataStoreDocRef.collection("user_settings")
                .addDocument(data: defaultSettingsDict)
            
            // Test
            try await sut.fetchCurrentUserSettings(userAccount: dummyUserAccount)
            
        } catch {
            XCTFail("Error throwed")
            return
        }
        
        // Check
        let fetchedUserSettings = sut.currentUserSettings
        
        XCTAssertEqual(fetchedUserSettings.letterSize, .medium)
        XCTAssertEqual(fetchedUserSettings.letterWeight, .normal)
        XCTAssertEqual(fetchedUserSettings.pushMorningEnabled, true)
        XCTAssertEqual(fetchedUserSettings.pushAfternoonEnabled, true)
        XCTAssertEqual(fetchedUserSettings.pushEveningEnabled, true)
        XCTAssertEqual(fetchedUserSettings.darkMode, .followDeviceSetting)

        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        do {
            // userSettings
            let userSettingsDocumentSnapshot = try await userDataStoreDocRef.collection("user_settings")
                .getDocuments()
            for userSettingsDocument in userSettingsDocumentSnapshot.documents {
                try await userSettingsDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
    
    func test_ユーザ設定を更新する() async {
        let usersCollectionRef = Firestore.firestore().collection("users")
        
        var dummyUserAccount = UserAccount(
            uid: UUID().uuidString,
            email: "testuser@example.com",
            displayName: "testuser"
        )
        
        let sut = UserSettingsManager.shared
        let userDataStoreDocRef: DocumentReference
        let userDataStoreDocumentId: String
        
        do {
            userDataStoreDocRef = try await usersCollectionRef.addDocument(data: [
                "uid": dummyUserAccount.uid,
                "displayName": dummyUserAccount.displayName
            ])
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        userDataStoreDocumentId = userDataStoreDocRef.documentID
        dummyUserAccount.setUserDataStoreDocumentId(userDataStoreDocumentId: userDataStoreDocumentId)
        let defaultSettingsDict = UserSettings.defaultSettings(uid: dummyUserAccount.uid).toDictionary()
        let userSettingsDocumentRef: DocumentReference
        do {
            userSettingsDocumentRef = try await userDataStoreDocRef.collection("user_settings")
                .addDocument(data: defaultSettingsDict)
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }
        
        var newUserSettings = UserSettings.defaultSettings(uid: dummyUserAccount.uid)
        newUserSettings.userSettingsDocumentId = userSettingsDocumentRef.documentID
        newUserSettings.letterSize = .large
        
        do {
            try await sut.updateUserSettings(by: newUserSettings, userAccount: dummyUserAccount)
        } catch {
            XCTFail("Error throwed: \(error.localizedDescription)")
            return
        }

        
        // Check
        let fetchedUserDataStoreDocRef = usersCollectionRef.document(userDataStoreDocRef.documentID)
        let userSettingsCollectionRef = fetchedUserDataStoreDocRef.collection("user_settings")
        do {
            guard let queryDocumentSnapshot = try await userSettingsCollectionRef.getDocuments().documents.first
            else {
                return
            }
            
            guard let fetchedUserSettings = UserSettings.fromSnapshot(snapshot: queryDocumentSnapshot)
            else {
                return
            }
            
            XCTAssertEqual(fetchedUserSettings.letterSize, .large) // changed
            XCTAssertEqual(fetchedUserSettings.letterWeight, .normal)
            XCTAssertEqual(fetchedUserSettings.pushMorningEnabled, true)
            XCTAssertEqual(fetchedUserSettings.pushAfternoonEnabled, true)
            XCTAssertEqual(fetchedUserSettings.pushEveningEnabled, true)
            XCTAssertEqual(fetchedUserSettings.darkMode, .followDeviceSetting)
        } catch {
            XCTFail("Error throwed")
            return
        }

        // tearDown
        // 全てのドキュメントを取得し
        // それぞれ削除する
        
        do {
            // userSettings
            let userSettingsDocumentSnapshot = try await userDataStoreDocRef.collection("user_settings")
                .getDocuments()
            for userSettingsDocument in userSettingsDocumentSnapshot.documents {
                try await userSettingsDocument.reference.delete()
            }
            
            // users
            let documentsSnapshot = try await usersCollectionRef
                .getDocuments()
            for document in documentsSnapshot.documents {
                try await document.reference.delete()
            }
        } catch {
            XCTFail("Throwed in deleting data")
            return
        }
    }
}

fileprivate extension UserSettings {
    static func fromSnapshot(snapshot: DocumentSnapshot) -> UserSettings? {
        guard let dictionary = snapshot.data()
        else { return nil }
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
