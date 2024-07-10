//
//  PostViewModel.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 8/31/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import ActiveLabel

struct PostViewModel {
    var post: Post
    
    var imageUrl: URL? { return URL(string: post.imageUrl) }
    
    var userProfileImageUrl: URL? { return URL(string: post.ownerImageUrl) }
    
    var username: String { return post.ownerUsername }
    
    var caption: String { return post.caption }
    
    var likes: Int { return post.likes }
    
    var bookmarkImageName: String { return post.didSave ? "bookmark.fill" : "bookmark" }
    
    var likeButtonTintColor: UIColor { return post.didLike ? .red : .primaryTextColor }
    
    var videoUrl: URL? {
        guard let videoUrl = post.videoUrl else { return nil }
        return URL(string: videoUrl)
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "like_selected" : "like_unselected"
        return UIImage(named: imageName)
    }
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        return formatter.string(from: post.timestamp.date, to: Date())
    }
    
    var customLabelType: ActiveType {
        return ActiveType.custom(pattern: "^\(username)\\b")
    }
    
    var enabledTypes: [ActiveType] {
        return [.mention, .hashtag, .url, customLabelType]
    }
    
    var configureLinkAttribute: ConfigureLinkAttribute {
        return { (type, attributes, isSelected) in
            var atts = attributes
            switch type {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 14)
            default: ()
            }
            return atts
        }
    }
    
    func customizeLabel(_ label: ActiveLabel) {
        label.customize { label in
            label.text = "\(username) \(caption)"
            label.customColor[customLabelType] = .primaryTextColor
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .primaryTextColor
            label.numberOfLines = 2
        }
    }

    init(post: Post) {
        self.post = post
    }
}
