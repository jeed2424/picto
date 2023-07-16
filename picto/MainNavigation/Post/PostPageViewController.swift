//
//  PostPageViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/15/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

protocol PostProfileDelegate {
    func tappedProfile(user: BMUser)
}

protocol PostPagingDelegate {
    func viewedNewPost(post: BMPost)
}

class PostPageViewController: UIViewController {

    @IBOutlet weak var pageControllerHolderView: UIView!
    lazy var pageViewController: UIPageViewController = {
       return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }()
    
    var posts = [BMPost]()
    var initialPost: BMPost!
    var currentPost: BMPost!
    var postVCs = [PostCommentViewController]()
    
    static func makeVC(post: BMPost, otherPosts: [BMPost]) -> PostPageViewController {
        let vc = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostPageViewController") as! PostPageViewController
        vc.initialPost = post
        vc.currentPost = post
        vc.posts = otherPosts
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupPages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNav(title: "\(self.initialPost!.user!.username!)'s Posts")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNav(title: "\(self.initialPost!.user!.username!)'s Posts")
        
        Timer.schedule(delay: 0.3) { (t) in
            if var pview = UserDefaults.standard.value(forKey: "post_view") as? Int {
                if pview == 10 {
                    showAlertPopupLong(title: "Press to Hide/Show Details", message: "Press on the photo or video for just a quick moment to hide and show the details shown at the bottom.", image: .get(name: "press", tint: .white))
                }
                UserDefaults.standard.setValue(Int(pview + 1), forKey: "post_view")
            } else {
                showAlertPopupLong(title: "Press to Hide/Show Details", message: "Press on the photo or video for just a quick moment to hide and show the details shown at the bottom.", image: .get(name: "press", tint: .white))
                UserDefaults.standard.setValue(1, forKey: "post_view")
            }
        }
    }
    
    func setupPages() {
        //set its datasource and delegate methods
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        self.pageViewController.view.frame = .zero
        
        for index in 0..<self.posts.count {
//            if self.posts[index].id! != self.initialPost!.id! {
//                let vc = PostCommentViewController.makeVC(post: self.posts[index], index: index, delegate: self)
//                self.postVCs.append(vc)
//            }
            let vc = PostCommentViewController.makeVC(post: self.posts[index], index: index, delegate: self, pagingDelegate: self)
            self.postVCs.append(vc)
        }
        if let initialIndex = self.posts.index(of: self.initialPost!) {
            self.postVCs[0].pageIndex = initialIndex
            self.postVCs[initialIndex].pageIndex = 0
            self.postVCs.swapAt(0, initialIndex)
        } else {
            let vc = PostCommentViewController.makeVC(post: self.currentPost!, index: 0, delegate: self, pagingDelegate: self)
            self.postVCs.append(vc)
        }
//        self.pageViewController.setViewControllers(self.postVCs, direction: .forward, animated: false, completion: nil)
//        self.pageViewController.setViewControllers([self.postVCs.first!], direction: .forward, animated: false, completion: nil)
        self.pageViewController.setViewControllers([self.postVCs.first!], direction: .forward, animated: false, completion: nil)
        self.addChild(self.pageViewController)
        
        
        //Add to holder view
        self.pageControllerHolderView.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        
       
        //Pin to super view - (holder view)
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewController.view.topAnchor.constraint(equalTo: self.pageControllerHolderView.topAnchor).isActive = true
        self.pageViewController.view.leftAnchor.constraint(equalTo: self.pageControllerHolderView.leftAnchor).isActive = true
        self.pageViewController.view.bottomAnchor.constraint(equalTo: self.pageControllerHolderView.bottomAnchor).isActive = true
        self.pageViewController.view.rightAnchor.constraint(equalTo: self.pageControllerHolderView.rightAnchor).isActive = true
        
//        DispatchQueue.main.async {
//            Timer.schedule(delay: 0.15) { (t) in
//                self.pageViewController.setViewControllers([self.postVCs.first!], direction: .forward, animated: false, completion: nil)
//            }
//        }
        
        self.currentPost = self.initialPost!
        self.setNav(title: "\(self.initialPost!.user!.username!)'s Posts")
        
    }
    
    func setNav(title: String) {
        self.navigationController?.makeNavigationBarTransparent()
        self.navigationController?.navigationBar.isTranslucent = true
//        self.navigationController?.navigationBar.backgroundColor = .clear
//        self.navigationController?.navigationBar.barTintColor = .clear
        self.setNavTitle(text: "", font: BaseFont.get(.bold, 18), letterSpacing: 0.1, color: .label)
        self.setBackBtn(color: .label, animated: false)
        self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
    }
    
    @objc func savePostAction() {
        print("should save post \(self.currentPost!.caption!)")
        addHaptic(style: .medium)
        BMPostService.make().savePost(post: self.currentPost!) { (response, usr) in
       //     ProfileService.make().user = usr!
            self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
        }
    }
    
    @objc func sharePostAction() {
        print("should save post \(self.currentPost!.caption!)")
        addHaptic(style: .medium)
        let title = BMUser.me().checkCollection(post: self.currentPost!) == true ? "Removed from Collection" : "Added to Collection"
        let message = BMUser.me().checkCollection(post: self.currentPost!) == true ? "\(self.currentPost!.user!.username!)'s post has been removed from your Collection. To view your Collection, go to your profile page." : "\(self.currentPost!.user!.username!)'s post has been added to your Collection. To view your Collection, go to your profile page."
        showAlertPopup(title: title, message: message, image: .get(name: "staricon", tint: .white))
        BMPostService.make().addToCollection(post: self.currentPost!) { (response, u) in
            self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
        }
//        BMPostService.make().savePost(post: self.currentPost!) { (response, usr) in
//            ProfileService.make().user = usr!
//            self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
//        }
    }

}

extension PostPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore
        viewController: UIViewController) -> UIViewController? {
        guard let beforePage = viewController as? PostCommentViewController else { return nil }
        let beforePageIndex = beforePage.pageIndex
        //since it is before we need to go back the index
        let newIndex = beforePageIndex - 1
        if newIndex < 0 { return nil }
        return self.postVCs[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let afterPage = viewController as? PostCommentViewController else { return nil }
        let afterPageIndex = afterPage.pageIndex
        //since it is after we need to go forword
        let newIndex = afterPageIndex + 1
        if newIndex < 0 || newIndex > self.postVCs.count - 1 { return nil }
//        return getPageFor(index: newIndex)
        return self.postVCs[newIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            let pastVCs = previousViewControllers as! [PostCommentViewController]
            let remVCs = Array(self.postVCs.prefix(pastVCs.count))
            if let currentVC = remVCs.first {
                print("setting current VC!")
//                self.currentPost = currentVC.post!
//                self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
            }
            
        }
    }

}

extension PostPageViewController: PostProfileDelegate {
    func tappedProfile(user: BMUser) {
        print("tapped profile of post user")
        let profile = UserProfileViewController.makeVC(user: user)
        self.push(vc: profile)
    }
}

extension PostPageViewController: PostPagingDelegate {
    func viewedNewPost(post: BMPost) {
        print("Setting paging post!")
        self.currentPost = post
        self.setPostNavItems(saveAction: #selector(self.savePostAction), shareAction: #selector(self.sharePostAction), post: self.currentPost!)
    }
}

