//
//  ProfileHeader.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 6/26/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: class {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
    func header(_ profileHeader: ProfileHeader, wantsToViewFollowersFor user: User)
    func header(_ profileHeader: ProfileHeader, wantsToViewFollowingFor user: User)
    func header(_ profileHeader: ProfileHeader, wantsToShowLink url: URL?)
    func headerWantsToShowSavedPostsOrStartChat(_ profileHeader: ProfileHeader)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var viewModel: ProfileHeaderViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    let filterBar = OptionFilterView()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 3
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.primaryTextColor, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var secondaryActionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageView?.tintColor = .white
        button.layer.cornerRadius = 3
        button.backgroundColor = .secondaryBackgroundColor
        button.addTarget(self, action: #selector(handleSecondaryAction), for: .touchUpInside)
        return button
    }()
    
    private let postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var websiteButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleOpenWebsite), for: .touchUpInside)
        return button
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .backgroundColor
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 16, paddingLeft: 12)
        profileImageView.setDimensions(height: 96, width: 96)
        profileImageView.layer.cornerRadius = 96 / 2
        
        let userDetailsStack = UIStackView(arrangedSubviews: [nameLabel, bioLabel, websiteButton])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        userDetailsStack.alignment = .leading
        
        let editBookmarkStack = UIStackView(arrangedSubviews: [editProfileFollowButton, secondaryActionButton])
        editBookmarkStack.axis = .horizontal
        editBookmarkStack.spacing = 10
        editBookmarkStack.distribution = .fillProportionally
        editProfileFollowButton.setHeight(32)
        secondaryActionButton.setDimensions(height: 32, width: 40)
        
        let stack = UIStackView(arrangedSubviews: [followingLabel, followersLabel, postsLabel])
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.rightAnchor, right: rightAnchor,
                     paddingLeft: 12, paddingRight: 12, height: 50)
        
        addSubview(editBookmarkStack)
        editBookmarkStack.anchor(top: stack.bottomAnchor, left: stack.leftAnchor,
                                 right: stack.rightAnchor, paddingTop: 12)
        
        addSubview(userDetailsStack)
        userDetailsStack.anchor(top: editBookmarkStack.bottomAnchor, left: leftAnchor,
                                right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 48)

        let bottomDivider = UIView()
        bottomDivider.backgroundColor = .lightGray
        
        addSubview(bottomDivider)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 50)
        
        bottomDivider.anchor(top: filterBar.bottomAnchor, left: leftAnchor, right: rightAnchor, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func handleEditProfileFollowTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, didTapActionButtonFor: viewModel.user)
    }
    
    @objc func handleFollowersTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, wantsToViewFollowersFor: viewModel.user)
    }
    
    @objc func handleFollowingTapped() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, wantsToViewFollowingFor: viewModel.user)
    }
    
    @objc func handleOpenWebsite() {
        guard let viewModel = viewModel else { return }
        delegate?.header(self, wantsToShowLink: viewModel.userWebsiteURL)
    }
    
    @objc func handleSecondaryAction() {
        delegate?.headerWantsToShowSavedPostsOrStartChat(self)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
                
        nameLabel.text = viewModel.fullname
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        
        editProfileFollowButton.setTitle(viewModel.followButtonText, for: .normal)
        editProfileFollowButton.backgroundColor = viewModel.followButtonBackgroundColor
        
        secondaryActionButton.setImage(UIImage(systemName: viewModel.secondaryButtonImageName), for: .normal)
                
        bioLabel.text = viewModel.user.bio
        bioLabel.isHidden = viewModel.shouldHideBio
        
        websiteButton.isHidden = viewModel.shouldHideLink
        websiteButton.setTitle(viewModel.userWebsiteURL?.absoluteString, for: .normal)
        
        postsLabel.attributedText = viewModel.numberOfPosts
        followersLabel.attributedText = viewModel.numberOfFollowers
        followingLabel.attributedText = viewModel.numberOfFollowing
    }
}
