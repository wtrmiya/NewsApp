//
//  TermViewModel.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/13.
//

import Foundation

final class TermViewModel: ObservableObject {
    @Published var term: Term = Term.emptyTerm
    
    private let termManager: TermManagerProtocol
    
    init(termManager: TermManagerProtocol = TermManager.shared) {
        self.termManager = termManager
    }
    
    @MainActor
    func populateLatestTerm() async {
        do {
            guard let latestTerm = try await termManager.getLatestTerm()
            else {
                self.term = Term.emptyTerm
                return
            }
            
            self.term = latestTerm
        } catch {
            print(error)
        }
    }
}
