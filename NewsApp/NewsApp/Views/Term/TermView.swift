//
//  TermView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI

struct TermView: View {
    @Binding var isShowing: Bool
    @ObservedObject private var termViewModel: TermViewModel
    
    init(isShowing: Binding<Bool>, termViewModel: TermViewModel) {
        self._isShowing = isShowing
        self.termViewModel = termViewModel
    }
    
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
    let appDC = AppDependencyContainer()
    return appDC.makeTermView(isShowing: .constant(true))
}
