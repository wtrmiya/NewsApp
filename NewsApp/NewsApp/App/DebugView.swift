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
    
    @ObservedObject private var authViewModel: AuthViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }
    
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
            .disabled(authViewModel.signedInUserAccount != nil)
            
            Button(action: {
                authViewModel.signOut()
            }, label: {
                Text("Sign Out")
            })
            .disabled(authViewModel.signedInUserAccount == nil)
        }
    }
    
    private var isSignedInString: String {
        if authViewModel.signedInUserAccount != nil {
            return "サインイン中"
        } else {
            return "サインアウト中"
        }
    }
    
    private func signUp() async {
        authViewModel.email = email
        authViewModel.password = password
        authViewModel.displayName = displayName
        await authViewModel.signUp()
    }
    
    private func signIn() async {
        authViewModel.email = email
        authViewModel.password = password
        await authViewModel.signIn()
    }
}

#Preview {
    let appDC = AppDependencyContainer()
    return appDC.makeDebugView()
}
