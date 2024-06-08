//
//  SignInView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var signInViewModel: SignInViewModel = SignInViewModel()
    @State private var isShowingAlert: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Text("Sign Up")
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button(action: {
                        print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                    }, label: {
                        Text("Cancel")
                    })
                }

                VStack {
                    VStack(alignment: .leading) {
                        Text("Email")
                        TextField("Input email", text: $signInViewModel.email)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading) {
                        Text("Password")
                        TextField("Input password", text: $signInViewModel.password)
                            .textFieldStyle(.roundedBorder)
                    }
                }

                HStack {
                    Spacer()
                    Button(action: {
                        Task {
                            await signIn()
                        }
                    }, label: {
                        Text("Sign In")
                    })
                    Spacer()
                }

                Spacer()
            }
        }
        .padding()
        .alert("Error", isPresented: $isShowingAlert, actions: {
            Button(action: {
                dismiss()
            }, label: {
                Text("OK")
            })
        }, message: {
            if let errorMessage = signInViewModel.errorMessage {
                Text(errorMessage)
            }
        })
        .onReceive(signInViewModel.$errorMessage, perform: { _ in
            if signInViewModel.errorMessage != nil {
                isShowingAlert = true
            }
        })
    }
    
    private func signIn() async {
        await signInViewModel.signIn()
    }
}

#Preview {
    SignInView()
}
