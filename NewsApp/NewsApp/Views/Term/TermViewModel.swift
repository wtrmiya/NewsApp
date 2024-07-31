//
//  TermViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation

final class TermViewModel: ObservableObject {
    @Published var term: Term = Term.emptyTerm
    
    @Published var errorMessage: String?
    
    private let termManager: TermManagerProtocol
    
    init(termManager: TermManagerProtocol = TermManager.shared) {
        self.termManager = termManager
    }
    
    @MainActor
    func populateLatestTerm() async {
        do {
            let latestTerm = try await termManager.getLatestTerm()
            self.term = latestTerm
        } catch {
            self.errorMessage = "error: \(error.localizedDescription)"
        }
    }
}
