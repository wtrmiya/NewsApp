//
//  ToastHandler.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/06/22.
//

import Foundation

enum ToastHandlerError: Error {
    
}

final class ToastHandler: ObservableObject {
    @Published private(set) var currentToastMessage: String?
    
    @Published var errorMessage: String?
    
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
        else {
            // ユーザへの影響は無いので、特に例外は投げない
            return
        }
        
        toastQueue.removeFirst()
        currentToastMessage = message
        
        currentToastShowingTask?.cancel()
        currentToastShowingTask = Task {
            do {
                try await Task.sleep(for: toastShowingDuration)
                if Task.isCancelled {
                    // 単にタスクがキャンセルされているだけなので、例外は投げない
                    return
                }
                skipCurrent(in: defaultToastHidingDuration)
            } catch {
                self.errorMessage = "Tastk.sleep failed. Try again: \(error.localizedDescription)"
            }
        }
    }
    
    @MainActor
    private func removeCurrentToast() {
        if currentToastMessage == nil {
            // 削除対象のメッセージが存在しないので、例外は投げない
            return
        }
        
        currentToastShowingTask?.cancel()
        currentToastMessage = nil
    }
}
