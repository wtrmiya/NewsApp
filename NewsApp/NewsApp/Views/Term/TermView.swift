//
//  TermView.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/05.
//

import SwiftUI
import MarkdownUI

struct TermView: View {
    @Binding var isShowing: Bool
    @ObservedObject private var termViewModel: TermViewModel
    
    init(isShowing: Binding<Bool>, termViewModel: TermViewModel) {
        self._isShowing = isShowing
        self.termViewModel = termViewModel
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(termViewModel.term.title)
                        .font(.title)
                    Spacer()
                        .frame(height: 20)
                    Text("発効日: \(termViewModel.term.formattedEffectiveDateDescription)")
                    Spacer()
                        .frame(height: 20)
                    Markdown(termViewModel.term.escapeRemovedBody)
                    Spacer()
                }
            }
            .navigationTitle("NewsApp利用規約")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
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
