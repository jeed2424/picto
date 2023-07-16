//
//  MainTabController.swift
//  InstagramFirestoreTutorial
//
//  Created by Stephen Dowless on 5/27/20.
//  Copyright © 2020 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase
//import YPImagePicker
import PixelSDK

//class MainTabController: UITabBarController {
class MainTabController: CustomTabBarController {
    
    // MARK: - Lifecycle
    let mockService = MockService.make()
    let authService = AuthenticationService.make()
    
//    override var user: User? {
//        didSet {
//            guard let user = user else { return }
//            mockService.user = user
//            configureViewControllers(withUser: user)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        checkIfUserIsLoggedIn()
//        fetchUser()
        configureViewControllers()
    }
    
    // MARK: - API
    
//    func fetchUser() {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//        UserService.fetchUser(withUid: uid) { user in
//            self.user = user
//            self.mockService.user = user
//        }
//    }
    
//    func checkIfUserIsLoggedIn() {
//        if Auth.auth().currentUser == nil {
//            DispatchQueue.main.async {
//                let controller = LoginController()
//                controller.delegate = self
//                let nav = UINavigationController(rootViewController: controller)
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: true, completion: nil)
//            }
//        } else {
//            self.authService.testLogin(completion: { (responseCode, user) in
//                if responseCode != .Success {
//                    DispatchQueue.main.async {
//                        let controller = LoginController()
//                        controller.delegate = self
//                        let nav = UINavigationController(rootViewController: controller)
//                        nav.modalPresentationStyle = .fullScreen
//                        self.present(nav, animated: true, completion: nil)
//                    }
//                } else {
//                    guard let uid = Auth.auth().currentUser?.uid else { return }
//                    UserService.fetchUser(withUid: uid) { user in
//                        self.user = user
//                        self.mockService.user = user
//                    }
//                }
//            })
//        }
//    }
    
    // MARK: - Helpers
    
    func configureViewControllers() {
        view.backgroundColor = .systemBackground
        self.delegate = self
        
//        let layout = UICollectionViewFlowLayout()
//        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedController(collectionViewLayout: layout))
        let feed = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeTestViewController.makeVC())
        
//        let search = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController(config: .all))
//
//        let imageSelector = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostController(config: .newPost))
//
//        let notifications = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsController())
//
//        let profileController = ProfileController(user: user)
//        let profile = templateNavigationController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: profileController)
        
        viewControllers = [feed, feed, feed, feed, feed]
        
        tabBar.tintColor = .black
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
//        let nav = UINavigationController(rootViewController: rootViewController)
        let nav = BaseNC(rootViewController: rootViewController)
        nav.tabBarItem.image = unselectedImage
        nav.tabBarItem.selectedImage = selectedImage
        nav.tabBarItem.selectedImage?.withTintColor(.white)
        nav.navigationBar.tintColor = .white
        return nav
    }
    
//    func didFinishPickingMedia(_ picker: YPImagePicker) {
//        picker.didFinishPicking { items, _ in
//            picker.dismiss(animated: false) {
//                guard let selectedImage = items.singlePhoto?.image else { return }
//
//                let controller = UploadPostController(config: .newPost)
//                controller.selectedImage = selectedImage
//                controller.delegate = self
//                controller.currentUser = self.user
//
//                let nav = UINavigationController(rootViewController: controller)
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: false, completion: nil)
//            }
//        }
//    }
} 

// MARK: - AuthenticationDelegate

extension MainTabController: AuthenticationDelegate {
    func authenticationDidComplete() {
//        fetchUser()
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITabBarControllerDelegate

//extension MainTabController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let index = viewControllers?.firstIndex(of: viewController)
//
//        if index == 2 {
//            var config = YPImagePickerConfiguration()
//            config.library.mediaType = .photo
//            config.shouldSaveNewPicturesToAlbum = false
//            config.startOnScreen = .library
//            config.screens = [.library]
//            config.hidesStatusBar = false
//            config.hidesBottomBar = false
//            config.library.maxNumberOfItems = 1
//
//            let picker = YPImagePicker(configuration: config)
//            picker.modalPresentationStyle = .fullScreen
//            present(picker, animated: true, completion: nil)
//
//            didFinishPickingMedia(picker)
//            return false
//        }
//        
//        return true
//    }
//}

// MARK: - UploadPostControllerDelegate

//extension MainTabController: UploadPostControllerDelegate {
//    func controllerDidFinishUploadingPost(_ controller: UploadPostController) {
//        selectedIndex = 0
//        controller.dismiss(animated: true, completion: nil)
//
//        guard let feedNav = viewControllers?.first as? UINavigationController else { return }
//        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
//        feed.handleRefresh()
//    }
//}

extension CustomTabBarController: UploadPostControllerDelegate {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController) {
        selectedIndex = 0
        controller.dismiss(animated: true, completion: nil)
        
        guard let feedNav = viewControllers?.first as? UINavigationController else { return }
        guard let feed = feedNav.viewControllers.first as? FeedController else { return }
        feed.handleRefresh()
    }
}
