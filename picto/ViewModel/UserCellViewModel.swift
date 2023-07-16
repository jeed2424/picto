//
//  UserCellViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 8/18/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import Foundation

struct UserCellViewModel {
    private let user: User
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var username: String {
        return user.username
    }
    
    var fullname: String {
        return user.fullname
    }
    
    init(user: User) {
        self.user = user
    }
}
