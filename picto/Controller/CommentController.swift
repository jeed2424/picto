////
////  CommentController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 9/1/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//
//private let reuseIdentifier = "CommentCell"
//
//class CommentController: UICollectionViewController {
//    
//    // MARK: - Properties
//    
//    private let post: Post
//    private var comments = [Comment]()
//    
//    private lazy var commentInputView: CustomInputAccesoryView = {
//        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
//        let cv = CustomInputAccesoryView(config: .comments, frame: frame)
//        cv.delegate = self
//        return cv
//    }()
//    
//    // MARK: - Lifecycle
//    
//    init(post: Post) {
//        self.post = post
//        super.init(collectionViewLayout: UICollectionViewFlowLayout())
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureCollectionView()
//        fetchComments()
//    }
//    
//    override var inputAccessoryView: UIView? {
//        get { return commentInputView }
//    }
//    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = true
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//    
//    // MARK: - API
//    
//    func fetchComments() {
//        CommentService.fetchComments(forPost: post.postId) { comments in
//            self.comments = comments
//            self.collectionView.reloadData()
//        }
//    }
//    
//    // MARK: - Helpers
//    
//    func configureCollectionView() {
//        navigationItem.title = "Comments"
//        
//        collectionView.backgroundColor = .white
//        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        collectionView.alwaysBounceVertical = true
//        collectionView.keyboardDismissMode = .interactive
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//
//extension CommentController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return comments.count
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
//        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
//        return cell
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//
//extension CommentController {
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let uid = comments[indexPath.row].uid
//        UserService.fetchUser(withUid: uid) { user in
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//
//extension CommentController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let viewModel = CommentViewModel(comment: comments[indexPath.row])
//        let height = viewModel.size(forWidth: view.frame.width).height + 32
//        return CGSize(width: view.frame.width, height: height)
//    }
//}
//
//// MARK: - CommentInputAccesoryViewDelegate
//
//extension CommentController: CustomInputAccesoryViewDelegate {
//    func inputView(_ inputView: CustomInputAccesoryView, wantsToUploadText text: String) {
//        guard let tab = tabBarController as? MainTabController else { return }
//        guard let currentUser = tab.user else { return }
//        
//        showLoader(true)
//        
//        CommentService.uploadComment(comment: text, post: post, user: currentUser) { error in
//            self.showLoader(false)
//            inputView.clearInputText()
//            
//            NotificationService.uploadNotification(toUid: self.post.ownerUid,
//                                                   fromUser: currentUser,
//                                                   type: .comment,
//                                                   post: self.post)
//        }
//    }
//}
