//
//  HashtagPostsController.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 10/14/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit

private let cellIdentifier = "PhotoCell"

enum PostsControllerConfig {
    case hashtags(String)
    case saved
    
    var navigationTitle: String {
        switch self {
        case .hashtags(let hashtag): return "#\(hashtag)"
        case .saved: return "Saved"
        }
    }
}

class PostsController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let config: PostsControllerConfig

    private var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }

    // MARK: - Lifecycle
    
    init(config: PostsControllerConfig) {
        self.config = config
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchPosts()
    }
    
    // MARK: - API
    
    func fetchPosts() {
        switch config {
        
        case .hashtags(let hashtag):
            PostService.fetchPosts(forHashtag: hashtag) { posts in
                self.posts = posts
            }
            
        case .saved:
            PostService.fetchSavedPosts { posts in
                self.posts = posts
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = config.navigationTitle

        collectionView.backgroundColor = .backgroundColor
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
}

// MARK: - UICollectionViewDataSource
extension PostsController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
        cell.viewModel = PostViewModel(post: posts[indexPath.row])
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PostsController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
        controller.post = posts[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PostsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
}
