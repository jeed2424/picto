//
//  ActionSheetViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 2/6/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation

struct ActionSheetViewModel {
    let user: User
    
//    var options: [ActionSheetOptions] {
//        var results = [ActionSheetOptions]()
//
//    }
}

enum ActionSheetOptions: CaseIterable {
    case settings
    case saved
    case liked
    
    var description: String {
        switch self {
        case .settings: return "Settings"
        case .saved: return "Saved Posts"
        case .liked: return "Liked Posts"
        }
    }
    
    var imageName: String {
        switch self {
        case .settings: return "gear"
        case .saved: return "bookmark"
        case .liked: return "heart"
        }
    }
}
