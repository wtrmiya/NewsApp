//
//  SignInView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignInView: View {
    @State private var isShowingAlert: Bool = false
    
    @Binding var isShowing: Bool
    @ObservedObject private var signInViewModel: SignInViewModel
    
    init(isShowing: Binding<Bool>, signInViewModel: SignInViewModel) {
        self._isShowing = isShowing
        self.signInViewModel = signInViewModel
    }

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
                isShowing = false
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
    let appDC = AppDependencyContainer()
    return appDC.makeSignInView(isShowing: .constant(true))
}
