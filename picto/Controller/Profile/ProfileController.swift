////
////  ProfileController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 5/27/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//import SafariServices
//
//private let cellIdentifier = "ProfileCell"
//private let headerIdentifier = "ProfileHeader"
//
//class ProfileController: UICollectionViewController {
//    
//    // MARK: - Properties
//    
//    private var selectedPostFilter: OptionFilterViewModel = .posts {
//        didSet { collectionView.reloadData() }
//    }
//    
//    private var currentDataSource: [Post] {
//        switch selectedPostFilter {
//        case .likes: return likedPosts
//        case .posts: return posts
//        }
//    }
//    
//    private var viewModel: ProfileHeaderViewModel {
//        didSet { collectionView.reloadData() }
//    }
//    
//    private lazy var actionSheet = ActionSheetLauncher(user: viewModel.user)
//    
//    private var posts = [Post]()
//    private var likedPosts = [Post]()
//    
//    // MARK: - Lifecycle
//    
//    init(user: User) {
//        self.viewModel = ProfileHeaderViewModel(user: user)
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
//        checkIfUserIsFollowed()
//        fetchUserStats()
//        fetchPosts()
//        fetchLikedPosts()
//    }
//    
//    // MARK: - Actions
//    
//    @objc func handleRefresh() {
//        posts.removeAll()
//        fetchPosts()
//        fetchLikedPosts()
//        
//        fetchUserStats()
//    }
//    
//    @objc func showActionSheet() {
//        actionSheet.delegate = self
//        actionSheet.show()
//    }
//    
//    // MARK: - API
//    
//    func checkIfUserIsFollowed() {
//        UserService.checkIfUserIsFollowed(uid: viewModel.user.uid) { isFollowed in
//            self.viewModel.user.isFollowed = isFollowed
//        }
//    }
//    
//    func fetchUserStats() {
//        UserService.fetchUserStats(uid: viewModel.user.uid) { stats in
//            self.viewModel.user.stats = stats
//            self.collectionView.reloadData()
//        }
//    }
//    
//    func fetchPosts() {
//        PostService.fetchPosts(forUser: viewModel.user.uid) { posts in
//            self.posts = posts
//            self.collectionView.reloadData()
//            self.collectionView.refreshControl?.endRefreshing()
//        }
//    }
//    
//    func fetchLikedPosts() {
//        PostService.fetchLikedPosts(viewModel.user.uid) { posts in
//            self.likedPosts = posts
//            self.collectionView.reloadData()
//        }
//    }
//    
//    // MARK: - Helpers
//    
//    func configureCollectionView() {
//        navigationItem.title = viewModel.user.username
//        collectionView.backgroundColor = .backgroundColor
//        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIdentifier)
//        collectionView.register(ProfileHeader.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: headerIdentifier)
//        
//        let refresher = UIRefreshControl()
//        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        collectionView.refreshControl = refresher
//        
//        if viewModel.user.isCurrentUser {
//            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
//                                                                style: .plain, target: self, action: #selector(showActionSheet))
//        }
//    }
//    
//    func showEditProfileController() {
//        let controller = EditProfileController(user: viewModel.user)
//        controller.delegate = self 
//        let nav = UINavigationController(rootViewController: controller)
//        nav.modalPresentationStyle = .fullScreen
//        present(nav, animated: true)
//    }
//}
//
//// MARK: - UICollectionViewDataSource
//
//extension ProfileController {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return currentDataSource.count
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCell
//        cell.viewModel = PostViewModel(post: currentDataSource[indexPath.row])
//        return cell
//    }
//    
//    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
//        header.delegate = self
//        header.filterBar.delegate = self
//        header.viewModel = viewModel
//        return header
//    }
//}
//
//// MARK: - UICollectionViewDelegate
//
//extension ProfileController {
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
//        controller.post = currentDataSource[indexPath.row]
//        navigationController?.pushViewController(controller, animated: true)
//    }
//}
//
//// MARK: - UICollectionViewDelegateFlowLayout
//
//extension ProfileController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (view.frame.width - 2) / 3
//        return CGSize(width: width, height: width)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        var height: CGFloat = 240
//        
//        if viewModel.user.bio != nil {
//            height += viewModel.size(forWidth: view.frame.width).height
//        }
//        
//        if viewModel.user.website != nil {
//            height += 20
//        }
//                
//        return CGSize(width: view.frame.width, height: height)
//    }
//}
//
//// MARK: - ProfileHeaderDelegate
//
//extension ProfileController: ProfileHeaderDelegate {
//    func header(_ profileHeader: ProfileHeader, wantsToShowLink url: URL?) {
//        guard let url = url else { return }
//        
//        let controller = SFSafariViewController(url: url)
//        present(controller, animated: true, completion: nil)
//    }
//    
//    func headerWantsToShowSavedPostsOrStartChat(_ profileHeader: ProfileHeader) {
//        if self.viewModel.user.isCurrentUser {
//            let controller = PostsController(config: .saved)
//            navigationController?.pushViewController(controller, animated: true)
//        } else {
//            let controller = ChatController(user: viewModel.user)
//            navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//    
//    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
//        guard let tab = tabBarController as? MainTabController else { return }
//        guard let currentUser = tab.user else { return }
//        
//        if user.isCurrentUser {
//            showEditProfileController()
//        } else if user.isFollowed {
//            UserService.unfollow(uid: user.uid) { error in
//                self.viewModel.user.isFollowed = false
//                
//                NotificationService.deleteNotification(toUid: user.uid, type: .follow)
//            }
//        } else {
//            UserService.follow(uid: user.uid) { error in
//                self.viewModel.user.isFollowed = true
//
//                NotificationService.uploadNotification(toUid: user.uid,
//                                                       fromUser: currentUser,
//                                                       type: .follow)
//            }
//        }
//    }
//    
//    func header(_ profileHeader: ProfileHeader, wantsToViewFollowersFor user: User) {
//        let controller = SearchController(config: .followers(user.uid))
//        navigationController?.pushViewController(controller, animated: true)
//    }
//    
//    func header(_ profileHeader: ProfileHeader, wantsToViewFollowingFor user: User) {
//        let controller = SearchController(config: .following(user.uid))
//        navigationController?.pushViewController(controller, animated: true)
//    }
//}
//
//// MARK: - EditProfileControllerDelegate
//
//extension ProfileController: EditProfileControllerDelegate {
//    func controller(_ controller: EditProfileController, wantsToUpdate user: User) {
//        controller.dismiss(animated: true, completion: nil)
//        self.viewModel.user = user
//    }
//}
//
//// MARK: - ActionSheetLauncherDelegate
//
//extension ProfileController: ActionSheetLauncherDelegate {
//    func didSelect(option: ActionSheetOptions) {
//        print("DEBUG: Option is \(option.description)")
//    }
//}
//
//// MARK; - OptionFilterViewDelegate
//
//extension ProfileController: OptionFilterViewDelegate {
//    func filterView(_ view: OptionFilterView, didSelect index: Int) {
//        guard let option = OptionFilterViewModel(rawValue: index) else { return }
//        self.selectedPostFilter = option
//    }
//}
