//
//  OptionFilterViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 3/1/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation

enum OptionFilterViewModel: Int, CaseIterable {
    case posts
    case likes
    
    var description: String {
        switch self {
        case .posts: return "Posts"
        case .likes: return "Likes"
        }
    }
}
