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
    @Published var didValuesChanged: Bool = false

    private let accountManager: AccountProtocol
    
    private var allCancellables = Set<AnyCancellable>()

    init(accountManager: AccountProtocol) {
        self.accountManager = accountManager
        
        bindDisplayNameValidation()
        bindEmailValidation()
        bindInputInfoValidation()
        bindDidValuesChanged()
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
    
    func resetInputValuesToDefault() {
        if let currentUserAccount = userAccount {
            inputDisplayName = currentUserAccount.displayName
            inputEmail = currentUserAccount.email
        }
    }
    
    func updateAccountInfo() {
        guard let userAccount = self.userAccount else { return }
        if userAccount.displayName != inputDisplayName {
            print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
        }
        
        if userAccount.email != inputEmail {
            print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
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
