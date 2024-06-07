//
//  SignInView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var signInViewModel: SignInViewModel = SignInViewModel()

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
    }
    
    private func signIn() async {
        await signInViewModel.signIn()
    }
}

#Preview {
    SignInView()
}
