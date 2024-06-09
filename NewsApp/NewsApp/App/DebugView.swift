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

    var body: some View {
        Form {
            Section {
                Text("Display Name: \(displayName)")
                Text("Email: \(email)")
                Text("Password: \(password)")
                Button(action: {
                    Task {
                        do {
                            try await AccountManager.shared.signUp(
                                email: email,
                                password: password,
                                displayName: displayName
                            )
                        } catch {
                            print(error)
                        }
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
                    do {
                        try await AccountManager.shared.signIn(email: email, password: password)
                    } catch {
                        print(error)
                    }
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
}

#Preview {
    DebugView()
}
