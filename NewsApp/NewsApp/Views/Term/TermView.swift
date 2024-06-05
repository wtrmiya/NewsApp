//
//  TermView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct TermView: View {
    var body: some View {
        NavigationStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, ")
                .navigationTitle("Term")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            print("NOT IMPLEMENTED: file: \(#file), line: \(#line)")
                        }, label: {
                            Text("Dismiss")
                        })
                    }
                }
        }
    }
}

#Preview {
    TermView()
}
