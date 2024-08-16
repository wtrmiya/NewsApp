//
//  AuthViewModelTests.swift
//  NewsAppTests
//
//  Created by Wataru Miyakoshi on 2024/08/15.
//

import XCTest
@testable import NewsApp

final class AuthViewModelTests: XCTestCase {
    func test_signUp_アカウント情報を設定しない場合_サインアップに失敗する() async {
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )
        
        await sut.signUp()
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertNil(sut.signedInUserAccount)
    }
    
    func test_signUp_アカウント情報を設定すると_サインアップに成功する() async {
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )
        
        sut.email = "testuser@example.com"
        sut.password = "password"
        sut.passwordRepeated = "password"
        sut.displayName = "testuser"

        await sut.signUp()
        XCTAssertNil(sut.errorMessage)
        XCTAssertNotNil(sut.signedInUserAccount)
    }

    func test_signIn_アカウント情報を設定しない場合_サインインに失敗する() async {
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )
        
        await sut.signIn()
        
        XCTAssertNil(sut.signedInUserAccount)
    }
    
    func test_signIn_サインアップしない場合_サインインに失敗する() async {
        let email = "testuser@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )

        sut.email = email
        sut.password = password
        sut.passwordRepeated = password
        sut.displayName = displayName
        
        await sut.signIn()
        
        XCTAssertNil(sut.signedInUserAccount)
    }
    
    func test_signIn_サインアップ後である場合_サインインに成功する() async {
        let email = "testuser@example.com"
        let password = "password"
        let displayName = "testuser"
        
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )

        sut.email = email
        sut.password = password
        sut.passwordRepeated = password
        sut.displayName = displayName
        
        await sut.signUp()
        await sut.signIn()
        
        XCTAssertNotNil(sut.signedInUserAccount)
    }
    
    func test_signOut_サインイン後の場合_サインアウトに成功する() async {
        let sut = AuthViewModel(
            accountManager: MockAccountManager(),
            userSettingsManager: MockUserSettingsManager(),
            userDataStoreManager: MockUserDataStoreManager(),
            pushNotificationManager: PushNotificationManager.shared
        )
        
        sut.email = "testuser@example.com"
        sut.password = "password"
        sut.passwordRepeated = "password"
        sut.displayName = "testuser"

        await sut.signUp()
        sut.signOut()
        
        XCTAssertNil(sut.errorMessage)
        
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000)
            XCTAssertNil(sut.signedInUserAccount)
        } catch {
            XCTFail("error throwed")
            return
        }
    }
}
