//
//  AccountSettingsViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/15.
//

import Foundation
import Combine

enum AccountSettingsViewModelError: Error {
    case noUserAccount
}

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
    
    @Published var inputPassword: String = ""
    @Published var isEditingEmail: Bool = false
    @Published var inputPasswordValid: Bool = true

    @Published var inputInfoValid: Bool = true
    @Published var didValuesChanged: Bool = false
    
    @Published var withdrawalPassword: String = ""
    @Published var withdrawalPasswordValid: Bool = true
    
    @Published var errorMessage: String?

    private let accountManager: AccountProtocol
    
    private var allCancellables = Set<AnyCancellable>()

    init(accountManager: AccountProtocol) {
        self.accountManager = accountManager
        
        bindDisplayNameValidation()
        bindEmailValidation()
        bindInputInfoValidation()
        bindDidValuesChanged()
        bindIsEditingEmail()
        bindPasswordValidation()
        bindWithdrawalPasswordValidation()
    }
    
    func populateUserAccount() {
        self.userAccount = accountManager.userAccount
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
    
    private func bindDidValuesChanged() {
        Publishers.CombineLatest($inputDisplayName, $inputEmail)
            .receive(on: DispatchQueue.main)
            .map { [weak self] newDisplayName, newEmail in
                guard let self else { return false }
                guard let userAccount  = self.userAccount else { return false }
                return (newDisplayName != userAccount.displayName)
                || (newEmail != userAccount.email)
            }
            .assign(to: \.didValuesChanged, on: self)
            .store(in: &allCancellables)
    }
    
    private func bindIsEditingEmail() {
        $inputEmail
            .receive(on: DispatchQueue.main)
            .map { [weak self] newEmail in
                guard let self else { return false }
                guard let userAccount  = self.userAccount else { return false }
                return newEmail != userAccount.email
            }
            .assign(to: \.isEditingEmail, on: self)
            .store(in: &allCancellables)
    }
    
    private func bindPasswordValidation() {
        Publishers.CombineLatest($isEditingEmail, $inputPassword)
            .receive(on: DispatchQueue.main)
            .map { nowEditingEmail, newInputPassword in
                if nowEditingEmail {
                    return newInputPassword.count > 0
                } else {
                    return true
                }
            }
            .assign(to: \.inputPasswordValid, on: self)
            .store(in: &allCancellables)
    }
    
    private func bindWithdrawalPasswordValidation() {
        $withdrawalPassword
            .receive(on: DispatchQueue.main)
            .map { $0.count > 0 }
            .assign(to: \.withdrawalPasswordValid, on: self)
            .store(in: &allCancellables)
    }

    func resetInputValuesToDefault() {
        if let currentUserAccount = userAccount {
            inputDisplayName = currentUserAccount.displayName
            inputEmail = currentUserAccount.email
        }
    }
    
    func updateAccountInfo() async {
        do {
            guard let userAccount = self.userAccount else {
                throw AccountSettingsViewModelError.noUserAccount
            }
            
            if userAccount.displayName != inputDisplayName {
                try await accountManager.updateDisplayName(displayName: inputDisplayName)
            }
            
            if userAccount.email != inputEmail {
                try await accountManager
                    .updateEmail(
                        currentEmail: userAccount.email,
                        password: inputPassword,
                        newEmail: inputEmail
                    )
            }
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() async {
        do {
            guard let userAccount = self.userAccount else {
                throw AccountSettingsViewModelError.noUserAccount
            }
            try await accountManager.deleteAccount(email: userAccount.email, password: withdrawalPassword)
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
}

fileprivate extension String {
    func isValidEmail() -> Bool {
        // swiftlint:disable:next force_try line_length
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        // swiftlint:disable:previous force_try line_length
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
}
