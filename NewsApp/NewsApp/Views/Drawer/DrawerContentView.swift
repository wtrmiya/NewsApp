//
//  DrawerContentView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct DrawerContentView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Yamada Tarou")
                Spacer()
                Button(action: {
                    print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                }, label: {
                    Image(systemName: "multiply")
                })
            }
            
            Spacer()
                .frame(height: 50)
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Bookmark")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Spacer()
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Terms")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Licenses")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
            Spacer()
                .frame(height: 50)
            Divider()
            Button(action: {
                print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
            }, label: {
                HStack {
                    Text("Sign Out")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            })
            Divider()
        }
        .padding()
    }
}

#Preview {
    DrawerContentView()
}
