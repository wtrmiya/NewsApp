//
//  ToastHandler.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/22.
//

import Foundation

final class ToastHandler: ObservableObject {
    @Published private(set) var currentToastMessage: String?
    
    private var toastQueue: [String] = [] {
        didSet {
            print(toastQueue)
        }
    }
    private var currentToastShowingTask: Task<Void, Never>?
    
    private var toastShowingDuration: Duration {
        .seconds(3)
    }
    
    private var defaultToastHidingDuration: Duration {
        .milliseconds(450)
    }
    
    @MainActor
    func queueMessage(_ message: String) {
        toastQueue.append(message)
        displayNextToastIfAvailable()
    }
    
    @MainActor
    func skipCurrent(in duration: Duration) {
        removeCurrentToast()
        Task {
            try? await Task.sleep(for: duration)
            displayNextToastIfAvailable()
        }
    }
    
    @MainActor
    private func displayNextToastIfAvailable() {
        guard currentToastMessage == nil,
              let message = toastQueue.first
        else { return }
        
        toastQueue.removeFirst()
        currentToastMessage = message
        
        currentToastShowingTask?.cancel()
        currentToastShowingTask = Task {
            do {
                try await Task.sleep(for: toastShowingDuration)
                if Task.isCancelled { return }
                skipCurrent(in: defaultToastHidingDuration)
            } catch {
                print("Tastk.sleep failed. Try again: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func removeCurrentToast() {
        if currentToastMessage == nil { return }
        
        currentToastShowingTask?.cancel()
        currentToastMessage = nil
    }
}
