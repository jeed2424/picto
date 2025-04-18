//
//  EditProfileViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 10/11/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Foundation

enum EditProfileOptions: Int, CaseIterable {
    case fullname
    case username
    case website
    case bio
    
    var description: String {
        switch self {
        case .username: return "Username"
        case .fullname: return "Name"
        case .website: return "Website"
        case .bio: return "Bio"
        }
    }
}

struct EditProfileViewModel {
    
    private let user: User
    let option: EditProfileOptions
    
    var titleText: String {
        return option.description
    }
    
    var optionValue: String? {
        switch option {
        case .username: return user.username
        case .fullname: return user.fullname
        case .bio: return user.bio
        case .website: return user.website
        }
    }
    
    var shouldHideTextView: Bool {
        return option != .bio
    }
    
    var shouldHidePlaceholderLabel: Bool {
        return user.bio != nil
    }
    
    
    init(user: User, option: EditProfileOptions) {
        self.user = user
        self.option = option
    }
}
