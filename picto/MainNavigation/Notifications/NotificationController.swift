//
//  NotificationController.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 5/27/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

//import UIKit
//
//private let reuseIdentifier = "NotificationCell"
//
//class NotificationsController: UITableViewController {
//    
//    // MARK: - Properties
//    
//    private var notifications = [Notification]() {
//        didSet { tableView.reloadData() }
//    }
//    
//    private let refresher = UIRefreshControl()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureTableView()
//        fetchNotifications()
//    }
//    
//    // MARK: - API
//    
//    func fetchNotifications() {
//        NotificationService.fetchNotifications { notifications in
//            self.notifications = notifications
//            self.checkIfUserIsFollowed()
//        }
//    }
//    
//    func checkIfUserIsFollowed() {
//        notifications.forEach { notification in
//            guard notification.type == .follow else { return }
//            
//            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in
//                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
//                    self.notifications[index].userIsFollowed = isFollowed
//                }
//            }
//        }
//    }
//    
//    // MARK: - Actions
//    
//    @objc func handleRefresh() {
//        notifications.removeAll()
//        fetchNotifications()
//        refresher.endRefreshing()
//    }
//    
//    // MARK: - Helpers
//    
//    func configureTableView() {
//        view.backgroundColor = .backgroundColor
//        navigationItem.title = "Notifications"
//        
//        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
//        tableView.rowHeight = 80
//        tableView.separatorStyle = .none
//        
//        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
//        tableView.refreshControl = refresher
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension NotificationsController {
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return notifications.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
//        cell.delegate = self
//        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
//        return cell
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension NotificationsController {
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        showLoader(true)
//        
//        UserService.fetchUser(withUid: notifications[indexPath.row].uid) { user in
//            self.showLoader(false)
//
//            let controller = ProfileController(user: user)
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//}
//
//// MARK: - NotificationCellDelegate
//
//extension NotificationsController: NotificationCellDelegate {
//    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
//        showLoader(true)
//
//        UserService.follow(uid: uid) { _ in
//            self.showLoader(false)
//            cell.viewModel?.notification.userIsFollowed.toggle()
//        }
//    }
//    
//    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
//        showLoader(true)
//
//        UserService.unfollow(uid: uid) { _ in
//            self.showLoader(false)
//            cell.viewModel?.notification.userIsFollowed.toggle()
//        }
//    }
//    
//    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
//        showLoader(true)
//
//        PostService.fetchPost(withPostId: postId) { post in
//            self.showLoader(false)
//            let controller = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
//            controller.post = post
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
//    }
//}
