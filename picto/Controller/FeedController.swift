////
////  FeedController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 5/27/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//import UIKit
//import Firebase
//
//private let reuseIdentifier = "Cell"
//
//class FeedController: UICollectionViewController {
//    
//    // MARK: - Lifecycle
//    
//    private var posts = [Post]() {
//        didSet { collectionView.reloadData() }
//    }
//    
//    var post: Post? {
//        didSet { collectionView.reloadData() }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        fetchPosts()
//        
//        if post != nil {
//            checkIfUserLikedPosts()
//            checkIfUserSavedPost()
//        }
//    }
//    
//    // MARK: - Actions
//    
//    @objc func handleRefresh() {
//        posts.removeAll()
//        fetchPosts()
//    }
//    
//    @objc func showMessages() {
//        let controller = ConversationsController()
//        navigationController?.pushViewController(controller, animated: true)
//    }
//    
//    @objc func handleLogout() {
//        do {
//            try Auth.auth().signOut()
//            let controller = LoginController()
//            controller.delegate = self.tabBarController as? MainTabController
//            let nav = UINavigationController(rootViewController: controller)
//            nav.modalPresentationStyle = .fullScreen
//            self.present(nav, animated: true, completion: nil)
//        } catch {
//            print("DEBUG: Failed to sign out")
//        }
//    }
//    
//    // MARK: - API
//    
//    func fetchPosts() {
//        guard post == nil else { return }
//        
//        PostService.fetchFeedPosts { posts in
//            self.posts = posts
//            self.checkIfUserLikedPosts()
//            self.checkIfUserSavedPost()
//            self.collectionView.refreshControl?.endRefreshing()
//        }
//    }
//    
//    func checkIfUserLikedPosts() {
//        if let post = post {
//            PostService.checkIfUserLikedPost(post: post) { didLike in
//                self.post?.didLike = didLike
//            }
//        } else {
//            posts.forEach { post in
//                PostService.checkIfUserLikedPost(post: post) { didLike in
//                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
//                        self.posts[index].didLike = didLike
//                    }
//                }
//            }
//        }
//    }
//    
//    func checkIfUserSavedPost() {
//        if let post = post {
//            PostService.checkIfUserSavedPost(post.postId) { didSave in
//                self.post?.didSave = didSave
//            }
//        } else {
//            posts.forEach { post in
//                PostService.checkIfUserSavedPost(post.postId) { didSave in
//                    if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
//                        self.posts[index].didSave = didSave
//                    }
//                }
//            }
//        }
//    }
//    
//    func deletePost(_ post: Post) {
//        self.showLoader(true)
//        
//        PostService.deletePost(post.postId) { _ in
//            self.showLoader(false)
//            self.handleRefresh()
//        }
//    }
//    
//    // MARK: - Helpers
//    
//    func configureUI() {
//        collectionView.backgroundColor = .backgroundColor
//        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        
//        if post == nil {
//            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self,
//                                                               action: #selector(handleLogout))
//            navigationItem.leftBarButtonItem?.tintColor = .white
//            
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self,
//                                                                action: #selector(showMessages))
//            navigationItem.rightBarButtonItem?.tintColor = .white
//
//        }
//            
//        navigationItem.title = "Feed"
//        
//        let refresher = UIRefreshControl()
//        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        collectionView.refreshControl = refresher
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//extension FeedController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return post == nil ? posts.count : 1
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
//        cell.delegate = self
//        
//        handleHashtagTapped(forCell: cell)
//        handleMentionTapped(forCell: cell)
//        
//        if let post = post {
//            cell.viewModel = PostViewModel(post: post)
//        } else {
//            cell.viewModel = PostViewModel(post: posts[indexPath.row])
//        }
//        
//        return cell
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//extension FeedController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = view.frame.width
//        var height = width + 8 + 40 + 8
//        height += 50
//        height += 60
//        
//        return CGSize(width: width, height: height)
//    }
//}
//
//// MARK: - FeedCellDelegate
//extension FeedController: FeedCellDelegate {
//    func cell(_ cell: FeedCell, wantsToShowProfileFor uid: String) {
//        UserService.fetchUser(withUid: uid) { user in
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//    
//    func cell(_ cell: FeedCell, wantsToShowOptionsForPost post: Post) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        
//        let editPostAction = UIAlertAction(title: "Edit Post", style: .default) { _ in
//            let controller = UploadPostController(config: .edit(post))
//            controller.delegate = self.tabBarController as? MainTabController
//            let nav = UINavigationController(rootViewController: controller)
//            self.tabBarController?.present(nav, animated: true)
//        }
//        
//        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { _ in
//            self.deletePost(post)
//        }
//        
//        let unfollowAction = UIAlertAction(title: "Unfollow", style: .default) { _ in
//            self.showLoader(true)
//            UserService.unfollow(uid: post.ownerUid) { _ in
//                self.showLoader(false)
//            }
//        }
//        
//        let followAction = UIAlertAction(title: "Follow", style: .default) { _ in
//            self.showLoader(true)
//            UserService.follow(uid: post.ownerUid) { _ in
//                self.showLoader(false)
//            }
//        }
//        
//        let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        if post.ownerUid == Auth.auth().currentUser?.uid {
//            alert.addAction(editPostAction)
//            alert.addAction(deletePostAction)
//        } else {
//            UserService.checkIfUserIsFollowed(uid: post.ownerUid) { isFollowed in
//                if isFollowed {
//                    alert.addAction(unfollowAction)
//                } else {
//                    alert.addAction(followAction)
//                }
//            }
//        }
//        
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
//    }
//    
//    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
//        let controller = CommentController(post: post)
//        navigationController?.pushViewController(controller, animated: true)
//    }
//    
//    func cell(_ cell: FeedCell, didLike post: Post) {
//        guard let tab = tabBarController as? MainTabController else { return }
//        guard let user = tab.user else { return }
//        guard let ownerUid = cell.viewModel?.post.ownerUid else { return }
//        
//        cell.viewModel?.post.didLike.toggle()
//        
//        if post.didLike {
//            PostService.unlikePost(post: post) { _ in
//                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
//                cell.likeButton.tintColor = .black
//                cell.viewModel?.post.likes = post.likes - 1
//                
//                NotificationService.deleteNotification(toUid: ownerUid, type: .like,
//                                                       postId: cell.viewModel?.post.postId)
//            }
//        } else {
//            PostService.likePost(post: post) { _ in
//                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
//                cell.likeButton.tintColor = .red
//                cell.viewModel?.post.likes = post.likes + 1
//                
//                NotificationService.uploadNotification(toUid: post.ownerUid,
//                                                       fromUser: user,
//                                                       type: .like, post: post)
//            }
//        }
//    }
//    
//    func cell(_ cell: FeedCell, wantsToViewLikesFor postId: String) {
//        let controller = SearchController(config: .likes(postId))
//        navigationController?.pushViewController(controller, animated: true)
//    }
//    
//    func cell(_ cell: FeedCell, didSave post: Post) {
//        if post.didSave {
//            PostService.unsavePost(post.postId) { _ in
//                cell.viewModel?.post.didSave = false
//            }
//        } else {
//            PostService.savePost(post.postId) { _ in
//                cell.viewModel?.post.didSave = true
//            }
//        }
//    }
//}
//
//// MARK: - ActiveLabelHandlers
//extension FeedController {
//    func handleHashtagTapped(forCell cell: FeedCell) {
//        cell.captionLabel.handleHashtagTap { hashtag in
//            let controller = PostsController(config: .hashtags(hashtag.lowercased()))
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//    
//    func handleMentionTapped(forCell cell: FeedCell) {
//        cell.captionLabel.handleMentionTap { username in
//            self.showLoader(true)
//            UserService.fetchUser(withUsername: username) { user in
//                self.showLoader(false)
//                
//                if let user = user {
//                    let controller = ProfileController(user: user)
//                    self.navigationController?.pushViewController(controller, animated: true)
//                } else {
//                    self.showMessage(withTitle: "Error", message: "User does not exist")
//                }
//            }
//        }
//    }
//}
