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
            ZStack {
                Color.surfacePrimary
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(termViewModel.term.title)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.bodyPrimary)
                        Spacer()
                            .frame(height: 24)
                        Text("発効日: \(termViewModel.term.formattedEffectiveDateDescription)")
                            .foregroundStyle(.bodyPrimary)
                        Spacer()
                            .frame(height: 24)
                        Markdown(termViewModel.term.escapeRemovedBody)
                            .foregroundStyle(.bodyPrimary)
                        Spacer()
                    }
                }
                .padding(16)
            }
            .navigationTitle("NewsApp利用規約")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.surfacePrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowing = false
                    }, label: {
                        Text("閉じる")
                            .foregroundStyle(.titleNormal)
                    })
                }
            }
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
