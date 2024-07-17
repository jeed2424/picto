//
//  HomeTestViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/8/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import VerticalCardSwiper
//import PixelSDK
import StoreKit
import SupabaseManager

protocol NewFeedItemDelegate {
    func createdNewItem(post: BMPost)
}

class HomeTestViewController: UIViewController {
    
    @IBOutlet weak var loadingInd: UIActivityIndicatorView!
    @IBOutlet weak var cardSwiper: VerticalCardSwiper! {
        didSet {
            cardSwiper.delegate = self
            cardSwiper.datasource = self
            cardSwiper.sideInset = 10
            cardSwiper.cardSpacing = 20
            cardSwiper.isStackOnBottom = false
//            cardSwiper.sw
            cardSwiper.layer.masksToBounds = false
            cardSwiper.clipsToBounds = false
            // register cardCell for storyboard use
            cardSwiper.register(nib: UINib(nibName: "CardCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CardCollectionViewCell")
            cardSwiper.reloadData()
            cardSwiper.layoutSubviews()
        }
    }
    
    var firstView = Date()
    let mockService = MockService.make()
    let feedService = FeedService.make()
    var feedItems = [FeedItem]()
    let mockDataCount: Int = 15
    var followingBtn = UIButton(type: .system)
    var DiscoverBtn = UIButton(type: .system)
    var rightEnabled = true
    
    // Way to easily init VC
    static func makeVC() -> HomeTestViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeTestViewController") as! HomeTestViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingInd.startAnimating()
//        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//            AnalyticsParameterItemID: "\(me.id!)"
//        ])
        self.cardSwiper.alpha = 0
        setNavBar(title: "Feed")
        if feedService.posts.isEmpty {
            feedService.getFeed(all: true) { (response, posts) in
                self.feedService.posts = posts
                var newCards: [Int] = []
                for index in 0..<posts.count {
                    newCards.append(index)
                }
                self.cardSwiper.insertCards(at: newCards)
                UIView.animate(withDuration: 0.2) {
                    self.cardSwiper.alpha = 1
                }
                Timer.schedule(delay: 0.2) { (t) in
                    self.loadingInd.stopAnimating()
                }
            }
        } else {
            var newCards: [Int] = []
            for index in 0..<self.feedService.posts.count {
                newCards.append(index)
            }
            
            self.cardSwiper.insertCards(at: newCards)
            UIView.animate(withDuration: 0.2) {
                self.cardSwiper.alpha = 1
            }
            Timer.schedule(delay: 0.2) { (t) in
                self.loadingInd.stopAnimating()
            }
        }
        
        self.updateFCMToken()
        if !(BMUser.me()?.notifications.isEmpty ?? true) {
            self.addRedDotAtTabBarItemIndex(index: 2)
        }
//        SKStoreReviewController.requestReview()
        Timer.schedule(delay: 0.5) { (t) in
            if var pview = UserDefaults.standard.value(forKey: "home_view") as? Int {
                if pview == 20 {
                    addHaptic(style: .soft)
//                    showAlertPopupVeryLong(title: "Create a Post on Gala", message: "\nWelcome to the Gala  👋\n\nHey \(me.firstName!), our community is super excited to have you on the app! Create your first post by tapping on the + icon in the top right.\n", image: .get(name: "cameraadd", tint: .systemBackground))
                    showAlertPopupVeryLong(title: "Create a Post on Gala", message: "\nWelcome to the Gala  👋\n\nHey Unknown Person, our community is super excited to have you on the app! Create your first post by tapping on the + icon in the top right.\n", image: .get(name: "cameraadd", tint: .systemBackground))
                }
                if pview == 10 || pview == 40 || pview == 70 {
                    SKStoreReviewController.requestReview()
                }
                UserDefaults.standard.setValue(Int(pview + 1), forKey: "home_view")
            } else {
                addHaptic(style: .soft)
                showAlertPopupVeryLong(title: "Create a Post on Gala",
                                       message: "hello my friend, welcome to Picto!",
                                       image: .get(name: "cameraadd", tint: .systemBackground))
                UserDefaults.standard.setValue(1, forKey: "home_view")
            }
        }
    }

    // \nWelcome to the Gala  👋\n\nHey \(me.firstName!), our community is super excited to have you on the app! Create your first post by tapping on the + icon in the top right.\n
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavBar(title: "Feed")
        AddTapGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavBar(title: "Feed")
        self.cardSwiper.reloadData()
        if self.firstView.minDiff(toDate: Date()) > 3 {
            self.firstView = Date()
            self.feedService.getFeed(all: true) { (response, posts) in
                self.feedService.posts = posts
                var newCards: [Int] = []
                for index in 0..<posts.count {
                    newCards.append(index)
                }
                self.cardSwiper.insertCards(at: newCards)
                self.cardSwiper.reloadData()
            }
        }
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setVideos(play: false)
    }
    
    // Do all navigation setup here
    func setNavBar(title: String) {
//        self.setLeftAvatarItem()
        self.setNavTitle(text: "", font: BaseFont.get(.bold, 20), letterSpacing: 0.1, color: .label)
//        self.setRightNavBtn(image: UIImage(systemName: "camera.aperture", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))!, color: .label, action: #selector(self.openCamera), animated: false)
        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.imagePickerShow), animated: false)
        self.setInviteEmoji()
        self.setFeedTopButtons(leftBtn: self.followingBtn, rightBtn: self.DiscoverBtn, rightEnabled: self.rightEnabled)
        self.addNavBtnTaps()
    }
    
    func addNavBtnTaps() {
        self.followingBtn.addTarget(self, action: #selector(self.followingTap), for: .touchUpInside)
        self.DiscoverBtn.addTarget(self, action: #selector(self.DiscoverTap), for: .touchUpInside)
    }
    
    func setVideos(play: Bool) {
        for index in 0..<self.feedService.posts.count {
            if let cell = self.cardSwiper.cardForItem(at: index) as? CardCollectionViewCell {
                if play {
                    if index == self.cardSwiper.focussedCardIndex! {
                        cell.play()
                    } else {
                        cell.pause()
                    }
                } else {
                    cell.pause()
                }
            }
        }
    }
    
    @objc func followingTap() {
        if self.rightEnabled == true {
            addHaptic(style: .light)
            self.simulateFeedOptionSwitch()
            self.cardSwiper.scrollToCard(at: 0, animated: false)
            FeedService.make().getFollowingFeed(all: true) { (response, posts) in
                self.feedService.posts = posts
                var newCards: [Int] = []
                for index in 0..<posts.count {
                    newCards.append(index)
                }
                self.cardSwiper.insertCards(at: newCards)
                self.cardSwiper.reloadData()
//                self.cardSwiper.scrollToCard(at: 0, animated: true)
            }
        }
        self.rightEnabled = false
        self.setNavBar(title: "Feed")
    }
    
    @objc func DiscoverTap() {
        if self.rightEnabled == false {
            addHaptic(style: .light)
            self.simulateFeedOptionSwitch()
            self.cardSwiper.scrollToCard(at: 0, animated: false)
            self.feedService.getFeed(all: true) { (response, posts) in
                self.feedService.posts = posts
                var newCards: [Int] = []
                for index in 0..<posts.count {
                    newCards.append(index)
                }
                self.cardSwiper.insertCards(at: newCards)
                self.cardSwiper.reloadData()
//                self.cardSwiper.scrollToCard(at: 0, animated: true)
            }
        }
        self.rightEnabled = true
        self.setNavBar(title: "Feed")
    }
    
    func simulateFeedOptionSwitch() {
//        self.feedService.posts = self.feedService.posts.shuffled()
        self.cardSwiper.reloadData()
//        self.setVideos(play: true)
    }
    
    func AddTapGestures(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PostCommentViewController.likePostAction))
//        doubleTap.delaysTouchesBegan = true
//        doubleTap.delaysTouchesEnded = true
        doubleTap.numberOfTapsRequired = 2
       // doubleTap.numberOfTouchesRequired = 1
        self.cardSwiper.addGestureRecognizer(doubleTap)
    }
}


extension HomeTestViewController: VerticalCardSwiperDelegate, VerticalCardSwiperDatasource {
    
    func numberOfCards(verticalCardSwiperView: VerticalCardSwiperView) -> Int {
        return self.feedService.posts.count
    }
    
    func sizeForItem(verticalCardSwiperView: VerticalCardSwiperView, index: Int) -> CGSize {
        let heightRatio = CGFloat(1.7)
        return CGSize(width: screenWidth, height: (screenWidth-30)*heightRatio)
    }
    
    func cardForItemAt(verticalCardSwiperView: VerticalCardSwiperView, cardForItemAt index: Int) -> CardCell {
        
        if let cell = verticalCardSwiperView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: index) as? CardCollectionViewCell {
            cell.nav = self.navigationController
            cell.setFeedItem(post: self.feedService.posts[index])
            cell.feedDelegate = self
            if let first = self.cardSwiper.indexesForVisibleCards.first, let last = self.cardSwiper.indexesForVisibleCards.last {
//                if (index >= first && index < last) || (index == 0 && self.cardSwiper.focussedCardIndex! == 0) || (index == last && index == self.feedService.posts.count - 1) {
//                    print("playing cell in cellFOR")
//                    cell.play()
//                } else {
//                    print("pausing cell in cellFOR")
//                    cell.pause()
//                }
                if index == last - first || index == 0 {
                    print("playing cell in cellFOR")
                    cell.play()
                } else if index == first {
                    print("pausing cell first in cellFOR")
                    cell.pause()
                } else {
                    print("pausing cell in cellFOR")
                    cell.pause()
                }
            }
            return cell
        }
        return CardCell()
    }
    
    func willSwipeCardAway(card: CardCell, index: Int, swipeDirection: SwipeDirection) {
        // called right before the card animates off the screen.
        if let cell = card as? CardCollectionViewCell {
            cell.pause()
            print("paused video when cell is about to be swiped away")
        }
        
        
//        if let shake = UserDefaults.standard.string(forKey: "shake") {
            if index < self.feedService.posts.count {
                self.feedService.posts.remove(at: index)
                if swipeDirection == .Left {
                    addHaptic(style: .success)
//                    self.feedService.posts.remove(at: index)
                } else {
//                    card.resetToCenterPosition()
//                    addHaptic(style: .error)
                    addHaptic(style: .success)
                }
                showAlertPopup(title: "Swiping Content", message: "Swipe left or right on a post to let us know you don't want to see this post again.", image: .get(name: "homeicon1-selected", tint: .systemBackground))
            }
//        } else {
//            UserDefaults.standard.setValue("shake", forKey: "yes")
////            cardS
//            showAlertPopup(title: "Swiping Content", message: "Swipe left on a post to let us know you don't want to see this post again.", image: .get(name: "homeicon1-selected", tint: .white))
//        }
    }
    
    //to handle video playing between cells
    func didEndScroll(verticalCardSwiperView: VerticalCardSwiperView) {

        let visible = self.cardSwiper.indexesForVisibleCards
        if let first = visible.first, let last = visible.last {
            for i in visible {
                let cell = self.cardSwiper.cardForItem(at: i) as! CardCollectionViewCell
                if (i == 0 && self.cardSwiper.focussedCardIndex! == 0) || (i > first && i < last) {
                    cell.play()
                } else {
                    cell.pause()
                }
            }
        }
        
    }
    
    func didDoubleTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        print("Double Tapped feed item at: \(index)")

    }
    
    func didTapCard(verticalCardSwiperView: VerticalCardSwiperView, index: Int) {
        print("tapped feed item at: \(index)")
        let posts = FeedService.make().posts
        let vc = PostPageViewController.makeVC(post: posts[index], otherPosts: posts)
        self.push(vc: vc)
    }
}

extension HomeTestViewController: FeedCardDelegate {
    //tapped avatar on card cell (would do whatever action here)
    func tappedUser(post: BMPost) {
        print("tapped user avatar on card!")
//        let profile = UserProfileViewController.makeVC(user: post.user!)
//        self.push(vc: profile)
        if let vc = UserProfileViewController.makeVC(user: post.user!) {
            self.navigationController?.navigationBar.isTranslucent = false
            vc.hidesBottomBarWhenPushed = true
            vc.view.superview?.layoutIfNeeded()
            vc.view.layoutIfNeeded()
            vc.fromSearch = true
    //        self.navigationController?.navigationBar.isTranslucent = true
            self.push(vc: vc)
        }
    }
    
    func showMenu(post: BMPost) {
        let actionSheet = ATActionSheet()
        let collection = ATAction(title: "Add to Collection", image: nil) {
            print("Collections")
            actionSheet.dismissAlert()
        }
        let share = ATAction(title: "Share Post", image: nil) {
            print("Share")
            actionSheet.dismissAlert()
        }
        let report = ATAction(title: "Report", image: nil, style: .destructive, completion: {
            print("Report")
            actionSheet.dismissAlert()
        })
        actionSheet.addActions([collection, share, report])
        present(actionSheet, animated: true, completion: nil)
    }

}

extension HomeTestViewController {
    @objc private func imagePickerShow() {
        self.showImagePicker(showCustomCamera: true)
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
                                      [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
//        let data = image?.jpegData(compressionQuality: 0.5)

//        self.avatar.image = image
//        self.avatarDidChange = true
//        self.avatarData = data
        
//        let storageManager = SupabasePostStorageManager.sharedInstance
//        
//        storageManager.uploadPost(user: <#T##UUID#>, image: <#T##Data#>, completion: <#T##(String?) -> ()#>)

        if let user = BMUser.me() {
            let postUploadVC = NewPostUploadViewController.makeVC(user: user, delegate: self, image: image, videoURL: nil)
            self.navigationController?.pushViewController(postUploadVC, animated: true)
        }

        print("Hello Image Selected")
//        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

// Check to see if the target viewController current is currently presenting a ViewController
import CDAlertView

func getMenu(post: BMPost, vc: UINavigationController?, completion: (() -> Void)?) {
    guard let user = BMUser.me() else { return }
    let actionSheet = ATActionSheet()
    let collection = ATAction(title: user.checkCollection(post: post) == true ? "Remove from Collection" : "Add to Collection", image: nil) {
        print("Collections")
        let title = user.checkCollection(post: post) == true ? "Removed from Collection" : "Added to Collection"
        let message = user.checkCollection(post: post) == true ? "\(post.user!.username!)'s post has been removed from your Collection. To view your Collection, go to your profile page." : "\(post.user!.username!)'s post has been added to your Collection. To view your Collection, go to your profile page."
        actionSheet.dismissAlertAnim(completed: {
            showAlertPopup(title: title, message: message, image: .get(name: "staricon", tint: .systemBackground))
        })
        BMPostService.make().addToCollection(post: post) { (response, u) in
            completion!()
        }

    }
    let profile = ATAction(title: "Go to \(post.user!.username!)", image: nil) {
        print("view profile")
        actionSheet.dismiss(animated: false) {
            DispatchQueue.main.async {
                if let newvc = UserProfileViewController.makeVC(user: post.user!) {
                    newvc.hidesBottomBarWhenPushed = true
                    vc?.pushViewController(newvc, animated: true)
                }
            }
        }
    }
    let share = ATAction(title: "Share Post", image: nil) {
        print("Share")
        actionSheet.dismissAlert()
    }
    let report = ATAction(title: "Report", image: nil, style: .destructive, completion: {
        print("Report")
        actionSheet.dismissAlert()
    })
    
    let delete = ATAction(title: "Delete Post", image: nil, style: .destructive, completion: {
        print("Delete post")
//        BMPostService.make().deletePost(post: post) { (response, u) in
//            if let usr = u {
//                ProfileService.make().user = usr
//                BMUser.save(user: &ProfileService.make().user!)
//                actionSheet.dismissAlertAnim(completed: {
//                    showAlertPopup(title: "Post Deleted", message: "Your post is no longer visible to other users. View your profile to see your visible posts.", image: .get(name: "homeicon1-selected", tint: .systemBackground))
//                })
//                completion!()
//            }
//        }
    })
    
    let place = ATAction(title: post.location ?? "", image: nil, style: .link, completion: {
        print("tapped place")
        actionSheet.dismiss(animated: false) {
            DispatchQueue.main.async {
                let cat = BMCategory(title: post.location ?? "")
                let newvc = CategoryViewController.makeVC(cat: cat)
                newvc.hidesBottomBarWhenPushed = true
                vc?.pushViewController(newvc, animated: true)
            }
        }
    })
    if let l = post.location {
        if !l.isEmpty {
            if post.user?.identifier == user.identifier {
                actionSheet.addActions([place, profile, share, delete])
            } else {
                actionSheet.addActions([place, collection, profile, share, report])
            }
        } else {
            if post.user?.identifier == user.identifier {
                actionSheet.addActions([profile, share, delete])
            } else {
                actionSheet.addActions([collection, profile, share, report])
            }
        }
    } else {
        if post.user?.identifier == user.identifier {
            actionSheet.addActions([profile, share, delete])
        } else {
            actionSheet.addActions([collection, profile, share, report])
        }
//        actionSheet.addActions([collection, profile, share, report])
    }
    if vc?.presentedViewController == nil {
        let base = BaseNC(rootViewController: actionSheet)
        base.modalPresentationStyle = .overFullScreen
        vc?.present(base, animated: true, completion: nil)
    }
}

func showAlertPopup(title: String, message: String, image: UIImage?) {
    var v = CDAlertView(title: title, message: message, type: .noImage)
    if let i = image {
        v = CDAlertView(title: title, message: message, type: .custom(image: i))
    }
    v.popupWidth = screenWidth - 80
    v.circleFillColor = .label
    v.alertBackgroundColor = .systemBackground
    v.autoHideTime = 5
    v.canHideWhenTapBack = true
    v.hasShadow = true
    v.hasRoundCorners = true
    v.isHeaderIconFilled = true
    v.titleFont = BaseFont.get(.bold, 16)
    v.messageFont = BaseFont.get(.regular, 14)
//    v.showAnimated()
}

func showAlertPopupLong(title: String, message: String, image: UIImage?) {
    var v = CDAlertView(title: title, message: message, type: .noImage)
    if let i = image {
        v = CDAlertView(title: title, message: message, type: .custom(image: i))
    }
    v.popupWidth = screenWidth - 80
    v.circleFillColor = .label
    v.alertBackgroundColor = .systemBackground
    v.autoHideTime = 10
    v.canHideWhenTapBack = true
    v.hasShadow = true
    v.hasRoundCorners = true
    v.isHeaderIconFilled = true
    v.titleFont = BaseFont.get(.bold, 16)
    v.messageFont = BaseFont.get(.regular, 14)
  //  v.showAnimated()
}

func showAlertPopupVeryLong(title: String, message: String, image: UIImage?) {
    var v = CDAlertView(title: title, message: message, type: .noImage)
    if let i = image {
        v = CDAlertView(title: title, message: message, type: .custom(image: i))
    }
    v.popupWidth = screenWidth - 60
//    v.
    v.circleFillColor = .label
    v.alertBackgroundColor = .systemBackground
    v.autoHideTime = 25
    v.canHideWhenTapBack = true
    v.hasShadow = true
    v.hasRoundCorners = true
    v.isHeaderIconFilled = true
    v.titleFont = BaseFont.get(.bold, 17)
    v.messageFont = BaseFont.get(.regular, 15)
//    v.mes
  //  v.showAnimated()
}

func addPostToCollection(post: BMPost) {
    showAlertPopup(title: "Added to Collection", message: "\(post.user!.username!)'s post has been added to your Collection. To view your Collection, go to your profile page.", image: .get(name: "staricon", tint: .systemBackground))
//    BMPostService.make().addToCollection(post: post) { (response, u) in
//        BMUser.save(user: &ProfileService.make().user!)
//    }
}

func getNotiMenu(post: BMPost, user: BMUser, vc: UINavigationController?, completion: (() -> Void)?) {
    let actionSheet = ATActionSheet()
    let profile = ATAction(title: "Go to \(user.username!)'s Profile  😀", image: nil) {
        print("view profile")
        actionSheet.dismiss(animated: false) {
            DispatchQueue.main.async {
                if let newvc = UserProfileViewController.makeVC(user: user) {
                    newvc.hidesBottomBarWhenPushed = true
                    vc?.pushViewController(newvc, animated: true)
                }
            }
        }
    }
    let post = ATAction(title: "View Post  📷", image: nil) {
        print("view post")
        actionSheet.dismiss(animated: false) {
            DispatchQueue.main.async {
                let newvc = PostPageViewController.makeVC(post: post, otherPosts: [BMPost]())
                newvc.hidesBottomBarWhenPushed = true
                vc?.pushViewController(newvc, animated: true)
            }
        }
    }

    actionSheet.addActions([profile, post])
    if vc?.presentedViewController == nil {
        let base = BaseNC(rootViewController: actionSheet)
        base.modalPresentationStyle = .overFullScreen
        vc?.present(base, animated: true, completion: nil)
    }
}
