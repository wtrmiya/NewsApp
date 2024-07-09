//
//  LetterAppearance.swift
//  NewsApp
//
//  Created by Wataru Miyakoshi on 2024/07/09.
//

import SwiftUI

enum LetterSize: Int {
    case small = 0
    case medium
    case large
    
    var bodyLetterSize: CGFloat {
        switch self {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        }
    }

    var categoryLetterSize: CGFloat {
        switch self {
        case .small: return 12
        case .medium: return 14
        case .large: return 16
        }
    }
    
    var captionLetterSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }
    
    var termTitleLetterSize: CGFloat {
        switch self {
        case .small: return 22
        case .medium: return 24
        case .large: return 26
        }
    }
}

enum LetterWeight: Int {
    case normal = 0
    case thick
    
    var bodyLetterWeight: Font.Weight {
        switch self {
        case .normal: return .medium
        case .thick: return .bold
        }
    }
    
    var thinLetterWeight: Font.Weight {
        switch self {
        case .normal: return .regular
        case .thick: return .medium
        }
    }
}
