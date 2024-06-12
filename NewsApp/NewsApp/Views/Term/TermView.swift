//
//  TermView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct TermView: View {
    @Binding var isShowing: Bool
    @StateObject private var termViewModel = TermViewModel()
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(termViewModel.term.title)
                    .font(.title)
                Spacer()
                    .frame(height: 20)
                Text(termViewModel.term.effectiveDate.description)
                Spacer()
                    .frame(height: 20)
                Text(termViewModel.term.body)
                Spacer()
            }
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
            .padding()
        }
        .task {
            await termViewModel.populateLatestTerm()
        }
    }
}

#Preview {
    TermView(isShowing: .constant(true))
}
