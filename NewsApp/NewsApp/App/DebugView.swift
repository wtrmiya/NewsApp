//
//  DebugView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/10.
//

import SwiftUI

struct DebugView: View {
    private let email: String = "testuser@example.com"
    private let password: String = "testuser"
    private let displayName: String = "testuser"
    
    @State private var isSignedIn: Bool = AccountManager.shared.isSignedIn
    
    @EnvironmentObject private var appDC: AppDependencyContainer
    private let signUpViewModel = SignUpViewModel()
    private let signInViewModel = SignInViewModel()

    var body: some View {
        Form {
            Section {
                Text("Display Name: \(displayName)")
                Text("Email: \(email)")
                Text("Password: \(password)")
                Button(action: {
                    Task {
                        await signUp()
                    }
                }, label: {
                    Text("Sign Up")
                })
            } header: {
                Text("Authentication Info")
            }
            
            Text("サインイン状態: \(isSignedInString)")
            
            Button(action: {
                Task {
                    await signIn()
                }
            }, label: {
                Text("Sign In")
            })
            .disabled(isSignedIn)
            
            Button(action: {
                Task {
                    do {
                        try AccountManager.shared.signOut()
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign Out")
            })
            .disabled(!isSignedIn)
        }
    }
    
    private var isSignedInString: String {
        if isSignedIn {
            return "サインイン中"
        } else {
            return "サインアウト中"
        }
    }
    
    private func signUp() async {
        signUpViewModel.email = email
        signUpViewModel.password = password
        signUpViewModel.displayName = displayName
        await signUpViewModel.signUp()
    }
    
    private func signIn() async {
        signInViewModel.email = email
        signInViewModel.password = password
        await signInViewModel.signIn()
    }
}

#Preview {
    DebugView()
}
