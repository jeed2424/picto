//
//  ChatCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 10/12/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UICollectionViewCell {

    // MARK: - Properties

    var viewModel: MessageViewModel? {
        didSet { configure() }
    }

    var bubbleLeftAnchor: NSLayoutConstraint!
    var bubbleRightAnchor: NSLayoutConstraint!

    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.textColor = .white
        return tv
    }()

    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPurple
        return view
    }()
    
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(profileImageView)
        profileImageView.anchor(left: leftAnchor, bottom: bottomAnchor, paddingLeft: 8, paddingBottom: -4)
        profileImageView.setDimensions(height: 32, width: 32)
        profileImageView.layer.cornerRadius = 32 / 2
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12

        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12

        NSLayoutConstraint.activate([
            bubbleContainer.topAnchor.constraint(equalTo: self.topAnchor),
            bubbleContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            bubbleContainer.widthAnchor.constraint(equalToConstant: 250),
        ])

//        bubbleLeftAnchor = bubbleContainer.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12)
//        bubbleLeftAnchor.isActive = false
//
//        bubbleRightAnchor = bubbleContainer.rightAnchor.constraint(equalTo: rightAnchor, constant: -12)
//        bubbleRightAnchor.isActive = false

        bubbleContainer.addSubview(textView)
        textView.anchor(top: bubbleContainer.topAnchor, left: bubbleContainer.leftAnchor,
                        bottom: bubbleContainer.bottomAnchor, right: bubbleContainer.rightAnchor,
                        paddingTop: 4, paddingLeft: 12, paddingBottom: 4, paddingRight: 12)
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers

    func configure() {
        guard let viewModel = viewModel else { return }

        bubbleContainer.backgroundColor = viewModel.messageBackgroundColor
        bubbleContainer.layer.borderWidth = viewModel.messageBorderWidth
        bubbleContainer.layer.borderColor = viewModel.messageBorderColor.cgColor
        
        textView.textColor = viewModel.messageTextColor
        textView.text = viewModel.messageText

        bubbleLeftAnchor.isActive = viewModel.leftAnchorActive
        bubbleRightAnchor.isActive = viewModel.rightAnchorActive

        profileImageView.isHidden = viewModel.shouldHideProfileImage
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
    }
}
