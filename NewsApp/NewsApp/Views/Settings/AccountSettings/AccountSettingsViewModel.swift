//
//  AccountSettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/15.
//

import Foundation
import Combine

final class AccountSettingsViewModel: ObservableObject {
    @Published var userAccount: UserAccount? {
        didSet {
            resetInputValuesToDefault()
        }
    }
    @Published var inputDisplayName: String = ""
    @Published var inputDisplayNameValid: Bool = true
    
    @Published var inputEmail: String = ""
    @Published var inputEmailValid: Bool = true
    
    @Published var inputInfoValid: Bool = true

    private let accountManager: AccountProtocol
    
    private var allCancellables = Set<AnyCancellable>()

    init(accountManager: AccountProtocol) {
        self.accountManager = accountManager
        
        bindDisplayNameValidation()
        bindEmailValidation()
        bindInputInfoValidation()
    }
    
    func populateUserAccount() {
        self.userAccount = accountManager.user
    }
    
    private func bindDisplayNameValidation() {
        $inputDisplayName
            .receive(on: DispatchQueue.main)
            .map { $0.count >= 3 }
            .assign(to: \.inputDisplayNameValid, on: self)
            .store(in: &allCancellables)
    }
    
    private func bindEmailValidation() {
        $inputEmail
            .receive(on: DispatchQueue.main)
            .map { $0.isValidEmail() }
            .assign(to: \.inputEmailValid, on: self)
            .store(in: &allCancellables)
    }
    
    private func bindInputInfoValidation() {
        Publishers.CombineLatest($inputDisplayNameValid, $inputEmailValid)
            .receive(on: DispatchQueue.main)
            .map { $0 && $1 }
            .assign(to: \.inputInfoValid, on: self)
            .store(in: &allCancellables)
    }
    
    func resetInputValuesToDefault() {
        if let currentUserAccount = userAccount {
            inputDisplayName = currentUserAccount.displayName
            inputEmail = currentUserAccount.email
        }
    }

    /*
    @MainActor
    func setupInputUserAccount(email: String, displayName: String, password: String) {
        guard let currentUserAccount = userAccount else { return }
        let inputUserAccount = UserAccount(
            uid: currentUserAccount.uid,
            email: email,
            displayName: displayName
        )
        
        self.inputUserAccount = inputUserAccount
        self.inputPassword = password
    }
     */
}

fileprivate extension String {
    func isValidEmail() -> Bool {
        // swiftlint:disable:next force_try line_length
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        // swiftlint:disable:previous force_try line_length
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
