//
//  SelectedViewItemEnv+Extensions.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/06.
//

import SwiftUI

enum SelectedViewItem {
    case home
    case bookmark
}

struct SelectedViewItemKey: EnvironmentKey {
    static let defaultValue: Binding<SelectedViewItem>? = nil
}

extension EnvironmentValues {
    var selectedViewItem: Binding<SelectedViewItem>? {
        get { self[SelectedViewItemKey.self] }
        set { self[SelectedViewItemKey.self] = newValue }
    }
}
