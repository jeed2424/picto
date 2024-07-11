//
//  UserProfileViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/18/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import SafariServices
import PixelSDK

enum ProfileContentType {
//    case photos
//    case videos
//    case collections
    case posts
    case collections
    case videos
}

class UserProfileViewController: UIViewController, UITableViewDelegate {

    var user: BMUser!

    var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
        }
    }
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentControl: SJFluidSegmentedControl!
    @IBOutlet weak var linkBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followersLbl: UILabel!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var linkHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (screenWidth/2 - 30), height: 215)
            layout.minimumInteritemSpacing = 20
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .vertical
            layout.sectionInset.left = 20
            layout.sectionInset.right = 20
            layout.sectionInset.top = 30
            layout.sectionInset.bottom = 100
            collectionView.collectionViewLayout = layout
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var linkBtnHeight: NSLayoutConstraint!
    var fromTab: Bool = false
    var fromSearch: Bool = false
    var contentType: ProfileContentType = .posts {
        didSet {
            if let u = self.user {
                if !u.posts.isEmpty {
                    switch contentType {
//                    case .photos:
//                        self.posts = u.posts.filter({$0.contentType() == .photo})
//                        self.resizeTable()
                    case .videos:
                        self.posts = u.posts.filter({$0.contentType() == .video})
//                        self.resizeTable()
                    case .posts:
                        self.posts = u.posts.filter({$0.contentType() == .video || $0.contentType() == .photo})
//                        self.resizeTable()
                    case .collections:
                        if let c = u.collection {
                            self.posts = c.posts.map({$0.post!})
//                            self.resizeTable()
                        } else {
                            self.posts = [BMPost]()
//                            self.resizeTable()
                            ProfileService.make().loadUser(user: self.user!) { (r, usr) in
                                if let u = usr {
                                    self.user = u
                                    self.setUser(user: self.user!)
                                    self.posts = u.collection!.posts.map({$0.post!})
                                    self.resizeTable()
                                }
                            }
                        }
                    }
                    self.resizeTable()
                } else {
                    switch contentType {
//                    case .photos:
//                        self.posts = [BMPost]()
//                        self.resizeTable()
                    case .videos:
                        self.posts = u.posts.filter({$0.contentType() == .video})
//                        self.resizeTable()
                    case .posts:
                        self.posts = u.posts.filter({$0.contentType() == .video || $0.contentType() == .photo})
//                        self.resizeTable()
                    case .collections:
                        if let c = u.collection {
                            self.posts = c.posts.map({$0.post!})
//                            self.resizeTable()
                        } else {
                            self.posts = [BMPost]()
//                            self.resizeTable()
                            ProfileService.make().loadUser(user: self.user!) { (r, usr) in
                                if let u = usr {
                                    self.user = u
                                    self.setUser(user: self.user!)
                                    self.posts = u.collection!.posts.map({$0.post!})
                                    self.resizeTable()
                                }
                            }
                        }
                    }
                    self.resizeTable()
                }
            }
        }
    }
    
    var posts = [BMPost]()
    var collections = [BMCollection]()
    var videoCount: Int = 0

    
    static func makeVC(user: BMUser, fromTab: Bool? = false) -> UserProfileViewController? {
        let vc = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
        vc?.user = user
        vc?.fromTab = fromTab ?? false
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.contentType = .photos
        self.addSwipes()
        self.setUser(user: self.user!)
        self.loadPosts(user: self.user!)
        segmentControl.alpha = 0
        segmentControl.textFont = BaseFont.get(.bold, 16)
        segmentControl.textColor = .systemGray2
        segmentControl.selectedSegmentTextColor = .systemGray2
        segmentControl.shadowShowDuration = 0.15
        segmentControl.shadowHideDuration = 0.15
        segmentControl.delegate = self
        segmentControl.dataSource = self
        segmentControl.setCurrentSegmentIndex(0, animated: true)
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.tableView.tableHeaderView!.layoutIfNeeded()
        refreshControl.addTarget(self, action: #selector(reloadProf), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        self.tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        self.setControlY()
        print("userID: \(self.user!.id)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNav(user: self.user!)
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.tableView.tableHeaderView!.layoutIfNeeded()
        self.tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.posts = p.sorted(by: {$0.createdAt! < $1.createdAt!})
//        self.user!.posts = self.posts.sorted(by: {$0.createdAt! < $1.createdAt!})
//        Timer.schedule(delay: 0.3) { (t) in
//            if self.user.identifier == BMUser.me()?.identifier {
//              //  self.user = nil// ProfileService.make().user!
//            }
//        }
//        self.setUser(user: self.user!)
        if self.user!.avatar != nil {
            avatar.setImage(string: self.user!.avatar!)
        }
        avatar.round()
        bioLbl.text = self.user!.bio ?? "No bio added yet"
        bioLbl.setLineHeight(lineHeight: 1.2)
//        linkBtn.setTitle(self.user!.website ?? nil, for: [])
        linkBtn.setTitle(nil, for: [])
        linkHeight.constant = 0
        let l = self.user!.website ?? ""
        if l.replacingOccurrences(of: " ", with: "") != "" {
            linkBtn.setTitle(l, for: [])
            linkHeight.constant = 30
        }
        self.setNavTitle(text: "\(self.user?.username ?? "")", font: BaseFont.get(.medium, 15))
        if self.user?.showName == true {
            self.usernameLbl.text = "\(self.user?.firstName ?? "") \(self.user?.lastName ?? "")"
        } else {
            self.usernameLbl.text = self.user?.username
        }
//        usernameLbl.text = "\(self.user!.firstName!) \(self.user!.lastName!)"
        if self.user?.identifier == BMUser.me()?.identifier {
            self.user = BMUser.me()
        }
        let t = self.contentType
        self.contentType = t
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.setNav(user: self.user!)
        if self.segmentControl.alpha < 1 {
            self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            if !self.posts.isEmpty {
                self.segmentControl.show(duration: 0.2)
            } else {
                self.segmentControl.show(duration: 0.2)
            }
        }
        self.setControlY()
        var when = DispatchTime.now() + 0.1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.setControlY()
        }
    }
    
    func setUser(user: BMUser) {
        self.user = user
        setNav(user: user)
        if user.avatar != nil {
            avatar.setImage(string: user.avatar!)
        }
        avatar.round()
        bioLbl.text = user.bio ?? "No bio added yet"
        bioLbl.setLineHeight(lineHeight: 1.2)
        linkBtn.setTitle(nil, for: [])
        linkHeight.constant = 0
        if let l = user.website {
            linkBtn.setTitle(l, for: [])
            linkHeight.constant = 30
        }
//        linkBtn.setTitle(user.website ?? nil, for: [])
        usernameLbl.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
        followersBtn.setTitle(user.followers.count.countText(text: "Follower"), for: [])
        followersLbl.text = user.followers.count.countText(text: "Follower")
        checkUser(user: user)
//        loadPosts(user: user)
        addAvatarTap(user: user)
    }
    
    @objc func reloadProf() {
        self.tableView.refreshControl?.beginRefreshing()
        self.setControlY()
        self.loadPosts(user: self.user!)
//        ProfileService.make().loadUser(user: self.user!) { (response, u) in
//            if let usr = u {
//                if usr.id! == BMUser.me()?.identifier {
//                    ProfileService.make().user = usr
//                }
//                self.user = usr
//                self.tableView.reloadData()
//                Timer.schedule(delay: 0.4) { (t) in
//                    self.tableView.refreshControl?.endRefreshing()
//                    self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
//                    self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//                    self.setControlY()
//                }
//            }
//        }
//        self.loadPosts(user: self.user!)
    }
    
    func addAvatarTap(user: BMUser) {
        if user.identifier == BMUser.me()?.identifier {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.editAvatar))
            self.avatar.addGestureRecognizer(tap)
            self.avatar.isUserInteractionEnabled = true
        }
    }
    
    func setNav(user: BMUser) {
        if self.fromTab {
            self.setNavTitle(text: "\(user.username!)", font: BaseFont.get(.medium, 15))
            self.setInviteEmoji()
//            let menuBtn = UIBarButtonItem(image: UIImage(named: "People")!, style: .done, target: self, action: #selector(self.viewFollowing))
//            menuBtn.tintColor = .label
//            self.navigationItem.setLeftBarButton(menuBtn, animated: false)
        } else {
            self.setBackBtn(color: .label, animated: false)
            self.setNavTitle(text: "\(user.username!)", font: BaseFont.get(.medium, 15))
        }
        if user.identifier == BMUser.me()?.identifier {
            let menuBtn = UIBarButtonItem(image: UIImage(named: "menuicon")!, style: .done, target: self, action: #selector(self.showMenu))
            menuBtn.tintColor = .label
            self.navigationItem.setRightBarButton(menuBtn, animated: false)
        } else {
            let menuBtn = UIBarButtonItem(title: "•••", style: .done, target: self, action: #selector(self.showMenu))
            menuBtn.tintColor = .label
            self.navigationItem.setRightBarButton(menuBtn, animated: false)
            let menuBtn1 = UIBarButtonItem(image: UIImage(named: "fi_send")!, style: .done, target: self, action: #selector(self.showMessages))
            menuBtn1.tintColor = .label
            self.navigationItem.setRightBarButtonItems([menuBtn1, menuBtn], animated: false)
//            UIImage(named: "fi_send")!
        }
    }
    
    @objc func showMessages() {
        let vc = ConversationViewController.makeVC(convo: nil, user: self.user!)
        self.push(vc: vc)
    }
    
    func checkUser(user: BMUser) {
        if BMUser.me()?.identifier == user.identifier {
            self.followBtn.setTitle("Edit Profile", for: [])
            self.followBtn.setTitleColor(.systemBlue, for: [])
        } else {
            if BMUser.me()?.checkFollow(user: user) == true {
                self.followBtn.setTitle("Following", for: [])
            } else {
                self.followBtn.setTitle("Follow", for: [])
            }
        }
    }
    
    func loadPosts(user: BMUser) {
        BMPostService.make().getUserPosts(user: user) { (response, p) in
            self.posts = p.sorted(by: {$0.createdAt! > $1.createdAt!})
            self.user!.posts = self.posts.sorted(by: {$0.createdAt! > $1.createdAt!})
            self.videoCount = self.user!.posts.filter({$0.contentType() == .video}).count
            self.collectionView.reloadData()
            self.collectionViewHeight.constant = CGFloat(self.posts.chunked(into: 2).count * 215) + 235
            self.tableView.reloadData()
            if self.contentType == .posts {
                self.contentType = .posts
            }
            self.segmentControl.reloadData()
            self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
            var when = DispatchTime.now() + 0.1
//            if self.fromTab {
//                when = DispatchTime.now() + 0.3
//            }
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self.setControlY()
                UIView.animate(withDuration: 0.2) {
                    self.segmentControl.alpha = 1
                }
            }
        }
    }
    
    func resizeTable() {
        self.collectionView.fadeReload()
        self.collectionViewHeight.constant = CGFloat(self.posts.chunked(into: 2).count * 215) + 235
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.setControlY()
    }
    
    func setControlY() {
        segmentControl.frame.size = self.segmentContainer.frame.size
        segmentControl.frame.origin.y = segmentContainer.globalPoint!.y
        segmentControl.frame.origin.x = segmentContainer.globalPoint!.x
        if self.fromSearch == true {
            self.segmentControl.frame.origin.y = self.segmentContainer.globalPoint!.y - self.statusBarHeight() - (self.navigationController?.navigationBar.frame.size.height)!
        }
    }
    
    @IBAction func followAction(_ sender: Any) {
        guard let user = BMUser.me(), let uid = user.identifier else { return }
        addHaptic(style: .medium)
        if BMUser.me()?.identifier == self.user.identifier {
//            self.showUserList(users: FeedService.make().posts.map({$0.user!}))
            let vc = NewEditProfileViewController.makeVC(user: user)
            self.push(vc: vc)
        } else {
            if BMUser.me()?.checkFollow(user: self.user!) == true {
                self.followBtn.setTitle("Follow", for: [])
                if let index = self.user!.followers.firstIndex(of: uid) {
                    self.user!.followers.remove(at: index)
                }
            } else {
                self.followBtn.setTitle("Following", for: [])
                self.user!.followers.append(uid)
            }
            self.followersBtn.setTitle(self.user!.followers.count.countText(text: "Follower"), for: [])
            self.followersLbl.text = self.user!.followers.count.countText(text: "Follower")
            BMUser.save(user: &self.user!)
//            ProfileService.make().followUser(user: self.user!) { (response, u) in
//                print("followed user")
//            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.fromSearch = false
        self.segmentControl.hide(duration: 0.3)
    }
    
    @IBAction func viewFollowers(_ sender: Any) {
//        let vc = UserFollowersViewController.makeVC(user: self.user!)
//        vc.forSearch = self.fromSearch
//        self.push(vc: vc)
    }
    
    @IBAction func viewWebsite(_ sender: Any) {
        var u = self.user!.website ?? ""
        if u != "" {
            if u.contains("http") == false {
                u = "http://\(u)"
            }
            if let url = URL(string: u) {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func viewFollowing() {
//        let vc = UserFollowersViewController.makeVC(user: self.user!, following: true)
////        vc.forSearch = self.fromSearch
//        self.push(vc: vc)
    }
    
    @objc func showMenu() {
        // Action Sheet
        let actionSheet = ATActionSheet()
        let nb = self.user.identifier == BMUser.me()?.identifier ? "Community Guidelines" : "Enable Notifications"
        let noti = ATAction(title: self.user.identifier == BMUser.me()?.identifier ? "Community Guidelines" : "Enable Notifications", image: nil) {
            print("Notifications")
            actionSheet.dismissAlertAnim {
                if nb == "Community Guidelines" {
                    if let url = URL(string: "https://www.trygala.com/community-guidelines") {
                        let vc = SFSafariViewController(url: url)
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    showAlertPopup(title: "Notifications Enabled", message: "You will now receive notifications whenever \(self.user!.username!) creates a new post.", image: .get(name: "notificationbell", tint: .systemBackground))
                }
            }
        }
        let insta = ATAction(title: "View Instagram", image: nil, style: .default) {
            print("Instagram")
            let vc = SFSafariViewController(url: URL(string: "https://www.instagram.com/\(self.user!.instagram!.replacingOccurrences(of: " ", with: ""))/")!)
            self.present(vc, animated: true, completion: {
                actionSheet.dismiss(animated: false, completion: nil)
            })
            actionSheet.dismissAlertAnim {
                let vc = SFSafariViewController(url: URL(string: "https://www.instagram.com/\(self.user!.instagram!.replacingOccurrences(of: " ", with: ""))/")!)
                self.present(vc, animated: true, completion:  nil)
            }
        }
        let follows = ATAction(title: "People I Follow  👋", image: nil, style: .default) {
            print("Following")
            actionSheet.dismissAlertAnim {
//                let vc = UserFollowersViewController.makeVC(user: me, following: true)
//                self.push(vc: vc)
            }
        }
        
        var showName = ATAction(title: "Hide My Name", image: nil, style: .default) {
            print("Hide name")
            actionSheet.dismissAlertAnim {
//                ProfileService.make().toggleName(user: me) { (response, u) in
//                    if let usr = u {
//                        ProfileService.make().user = usr
//                        BMUser.save(user: &ProfileService.make().user!)
//                    }
//                }
            }
        }
        
//        if me.showName! == false {
//            showName = ATAction(title: "Show My Name", image: nil, style: .default) {
//                print("show name")
//                actionSheet.dismissAlertAnim {
////                    ProfileService.make().toggleName(user: me) { (response, u) in
////                        if let usr = u {
////                            ProfileService.make().user = usr
////                            BMUser.save(user: &ProfileService.make().user!)
////                        }
////                    }
//                }
//            }
//        }
        
        let likes = ATAction(title: "Posts I've Liked  ❤️", image: nil, style: .default) {
            print("Posts")
            actionSheet.dismissAlertAnim {
                DispatchQueue.main.async {
                    let cat = BMCategory(title: "Liked Posts")
                    let newvc = CategoryViewController.makeVC(cat: cat)
                    newvc.hidesBottomBarWhenPushed = true
                    self.fromSearch = true
                    self.push(vc: newvc)
                }
            }
        }
        let tb = self.user.identifier == BMUser.me()?.identifier ? "Terms of Service" : "Block \(self.user!.username!)"
        let block = ATAction(title: self.user.identifier == BMUser.me()?.identifier ? "Terms of Service" : "Block \(self.user!.username!)", image: nil, style: self.user.identifier == BMUser.me()?.identifier ? .default : .destructive) {
            print("block")
//            actionSheet.dismissAlert()
            actionSheet.dismissAlertAnim {
                if tb == "Terms of Service" {
                    if let url = URL(string: "https://www.trygala.com/termsofservice") {
                        let vc = SFSafariViewController(url: url)
                        self.present(vc, animated: true, completion: nil)
                    }
                } else {
                    showAlertPopup(title: "Coming Soon", message: "We're currently working on this feature and will have it available soon!", image: .get(name: "notificationbell", tint: .systemBackground))
                }
//                showAlertPopup(title: "Coming Soon", message: "We're currently working on this feature and will have it available soon!", image: .get(name: "notificationbell", tint: .white))
            }
        }
        let logout = ATAction(title: self.user.identifier == BMUser.me()?.identifier ? "Log out" : "Report Activity", image: nil, style: .default) {
            print("logged out")
            actionSheet.dismiss(animated: false) {
                AuthenticationService.make().logout {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

        let donate = ATAction(title: "Donate", image: nil, style: .default) {
            print("Donate")
            actionSheet.dismissAlertAnim {
                if let url = URL(string: "https://withkoji.com/@pictogram") {
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        
        let i = self.user!.instagram ?? ""
        if i != "" {
//            actionSheet.addActions([noti, insta, block, logout])
            if self.user.identifier == BMUser.me()?.identifier {
                actionSheet.addActions([showName, likes, follows, insta, noti, block, donate, logout])
            } else {
                actionSheet.addActions([insta, noti, block, logout])
            }
        } else {
            if self.user.identifier == BMUser.me()?.identifier {
                actionSheet.addActions([showName, likes, follows, noti, block, donate, logout])
            } else {
                actionSheet.addActions([noti, block, logout])
            }
        }
//        actionSheet.addActions([noti, insta, block, logout])
        present(actionSheet, animated: true, completion: nil)
    }
    
    override public func editController(_ editController: EditController, didFinishEditing session: Session) {
        editController.presentLoadingAlertModal(animated: true, completion: nil)
        
//        ImageExporter.shared.export(image: session.image!, compressionQuality: 0.5) { (error, img) in
//            self.avatar.image = img!
//            ProfileService.make().uploadToFirebaseImage(user: BMUser.me(), image: img!) { (imgUrl) in
//                ProfileService.make().user!.avatar = imgUrl
//                ProfileService.make().updateAvatar(user: BMUser.me()) { (response, u) in
//                    if let usr = u {
//                        ProfileService.make().user = usr
//                        self.tableView.reloadData()
//                    }
//                    editController.dismissLoadingAlertModal(animated: true) {
//                        editController.dismiss(animated: true, completion: nil)
//                    }
//                }
//            } failure: { (error) in
//                print("error: ", error)
//                editController.dismissLoadingAlertModal(animated: true) {
//                    editController.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    func addSwipes() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe))
        let right = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe))
        left.direction = .left
        right.direction = .right
        self.tableView.addGestureRecognizer(left)
        self.tableView.addGestureRecognizer(right)
    }
    
    @objc func rightSwipe() {
        if self.segmentControl.currentSegment != 0 {
            self.segmentControl.setCurrentSegmentIndex(self.segmentControl.currentSegment - 1, animated: true)
        }
    }
    
    @objc func leftSwipe() {
        if self.segmentControl.currentSegment != self.segmentControl.segmentsCount - 1 {
            self.segmentControl.setCurrentSegmentIndex(self.segmentControl.currentSegment + 1, animated: true)
        }
    }

}

extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedPostCell", for: indexPath) as! RelatedPostCell
        cell.setPost(post: self.posts[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let posts = self.posts
        let vc = PostPageViewController.makeVC(post: self.posts[indexPath.row], otherPosts: posts)
        self.fromSearch = false
        self.push(vc: vc)
    }
    
}

extension UserProfileViewController: SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {
    
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return !self.user!.posts.filter({$0.contentType() == .video}).isEmpty ? 3 : 2
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        
        if !self.user!.posts.filter({$0.contentType() == .video}).isEmpty {
            if index == 0 {
                return "Posts"
            } else if index == 1 {
                return "Videos"
            } else {
    //            return "Videos"
                return "Collection"
            }
        } else {
            if index == 0 {
                return "Posts"
            } else {
    //            return "Videos"
                return "Collection"
            }
        }
//        if index == 0 {
//            return "Posts"
//        } else if index == 1 {
//            return "Videos"
//        } else {
////            return "Videos"
//            return "Collection"
//        }
//        } else {
////            return "Collections"
//        }
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, titleColorForSelectedSegmentAtIndex index: Int) -> UIColor {
        return .label
    }
    
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForSelectedSegmentAtIndex index: Int) -> [UIColor] {
        return [.clear]
    }

    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        return [.clear, .clear]
    }
    
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl, didChangeFromSegmentAtIndex fromIndex: Int, toSegmentAtIndex toIndex: Int) {
        if !self.user!.posts.filter({$0.contentType() == .video}).isEmpty {
            switch toIndex {
            case 0:
                self.contentType = .posts
            case 1:
                self.contentType = .videos
            case 2:
                self.contentType = .collections
            default:
                self.contentType = .posts
            
            }
        } else {
            switch toIndex {
            case 0:
                self.contentType = .posts
            case 1:
                self.contentType = .collections
            default:
    //            self.contentType = .photos
                self.contentType = .posts
            
            }
        }
        print("Showing Content Type: ", self.contentType)
    }
}

extension UserProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("OFFSET: ", scrollView.contentOffset.y)
        if self.segmentContainer.globalPoint!.y <= 90 {
            self.segmentControl.frame.origin.y = 90
        } else {
//            self.segmentControl.frame.origin.y = self.segmentContainer.globalPoint!.y
            self.setControlY()
        }
    }
}
