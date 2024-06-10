//
//  TermView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct TermView: View {
    @Binding var isShowing: Bool
    var body: some View {
        NavigationStack {
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, ")
                .navigationTitle("Term")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isShowing = false
                        }, label: {
                            Text("Dismiss")
                        })
                    }
                }
        }
    }
}

#Preview {
    TermView(isShowing: .constant(true))
}
