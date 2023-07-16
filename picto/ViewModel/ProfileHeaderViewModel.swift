//
//  ProfileHeaderViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 8/13/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit

struct ProfileHeaderViewModel {
    var user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser {
            return "Edit Profile"
        }
        
        return user.isFollowed ? "Following" : "Follow"
    }
    
    var followButtonBackgroundColor: UIColor {
        return user.isCurrentUser ? .secondaryBackgroundColor : .systemBlue
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStatText(value: user.stats.followers, label: "followers")
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedStatText(value: user.stats.following, label: "following")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStatText(value: user.stats.likes, label: "likes")
    }
        
    var secondaryButtonImageName: String { return user.isCurrentUser ? "bookmark" : "paperplane.fill" }
    
    var userWebsiteURL: URL? {
        guard var urlString = user.website else { return nil }
                
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "http://".appendingFormat(urlString)
        }

        return URL(string: urlString)
    }
    
    var shouldHideBio: Bool { return user.bio == nil || user.bio == "" }
    
    var shouldHideLink: Bool { return user.website == nil || user.website == "" }
    
    init(user: User) {
        self.user = user
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    
    func size(forWidth width: CGFloat) -> CGSize {
        let measurementLabel = UILabel()
        measurementLabel.text = user.bio
        measurementLabel.numberOfLines = 0
        measurementLabel.lineBreakMode = .byWordWrapping
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        measurementLabel.widthAnchor.constraint(equalToConstant: width).isActive = true
        return measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
