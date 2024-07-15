import UIKit
import UITextView_Placeholder
import AVKit
import AVFoundation

class PostCommentViewController: UIViewController {
    
    @IBOutlet weak var tableView: ExpandingTableView!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var imgScrollView: ImageScrollView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet private var videoPlayer: PlayerView! {
        didSet {
            videoPlayer.playerLayer.videoGravity = .resizeAspectFill
            videoPlayer.videoViewDelegate = self
            videoPlayer.playOnLoad = false
            videoPlayer.start()
        }
    }
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var relatedBtn: UIButton!
    
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textContainerImg: UIImageView!
    @IBOutlet weak var textContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var postBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var imgRatio: NSLayoutConstraint!
    @IBOutlet weak var imgTop: NSLayoutConstraint!
    @IBOutlet weak var imgHeight: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    
    var pageIndex: Int = 0
    var post: BMPost!
    var relatedPosts = [BMPost]()
    var comments = [BMPostComment]()
    var delegate: PostProfileDelegate?
    var pagingDelegate: PostPagingDelegate?
    var commentForReply: BMPostComment!
    var subCommentForReply: BMPostSubComment!
    var showingRelated: Bool = false
    let tap2 = UILongPressGestureRecognizer(target: self, action: #selector(showInfo))
    var placeholder = "Add a 🔥 caption to this post..."
    
    static func makeVC(post: BMPost, index: Int, delegate: PostProfileDelegate?, pagingDelegate: PostPagingDelegate?) -> PostCommentViewController {
        let vc = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostCommentViewController") as! PostCommentViewController
        vc.post = post
        vc.delegate = delegate
        vc.pagingDelegate = pagingDelegate
        vc.pageIndex = index
        vc.placeholder = "Add a comment..."
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("setting view did load")
        self.imgTop.constant = self.statusBarHeight()
        imgScrollView.setup()
        imgScrollView.imageScrollViewDelegate = self
        imgScrollView.alpha = 0
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
//        DispatchQueue.main.async {
            self.setPost(post: self.post!)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("setting view will appear")
        setPost(post: self.post!)
        NotificationCenter.default.addObserver(self, selector: #selector(PostCommentViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PostCommentViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if let user = BMUser.me() {
            self.textContainerImg.setImage(string: user.avatar ?? "")
        }
        self.textContainerImg.round()
        self.tableView.reloadData()
        self.navigationController?.navigationBar.alpha = 1
        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("setting view did appear")
        self.tableView.reloadData()
        self.videoPlayer.playOnLoad = true
        if let d = self.pagingDelegate {
            d.viewedNewPost(post: self.post!)
        }
//        Timer.schedule(delay: 0.1) { (t) in
//            self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        }
        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.navigationController?.navigationBar.alpha = 1
        
//        var pview = UserDefaults.standard.integer(forKey: "post_view")
//        if pview == 0 || pview == 10 {
//            
//        }
//        UserDefaults.standard.setValue(pview += 1, forKey: "post_view")
    }
    
    func setPost(post: BMPost) {
        self.comments = post.comments
        self.gradientView.applyGradient(colors: [UIColor.black.withAlphaComponent(0.0), UIColor.black.withAlphaComponent(0.1),  UIColor.black.withAlphaComponent(0.7)], type: .vertical)
        self.setFollow(user: post.user!)
        self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
        self.likeBtn.tintColor = .white
        self.checkLikeBtn(fill: false)
        self.volumeBtn.setImage(.get(name: "volumeonicon", tint: UIColor.white.withAlphaComponent(0.8)), for: [])
        self.commentBtn.setImage(.get(name: "chatoutline", tint: .white), for: [])
        self.volumeBtn.alpha = 0
        self.videoPlayer.alpha = 0
        self.userAvatar.setImage(string: post.user!.avatar!)
        self.userAvatar.round()
        self.usernameLbl.text = post.user!.username!
        self.captionLbl.text = post.caption!.removeTags()
        self.captionLbl.textDropShadow()
        self.dateLbl.textDropShadow()
        self.usernameLbl.textDropShadow()
        self.dateLbl.text = post.createdAtText()
        self.likeCountLbl.text = "\(post.likeCount!)"
        self.commentCountLbl.text = "\(post.commentCount!)"
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = post.medias.count
        self.pageControl.hidesForSinglePage = true
        
        let media = post.medias.first!
        if let image = media.image {
            self.postImgView.image = image
        } else if let imgURL = media.imageUrl {
            self.postImgView.setImage(string: imgURL) { (img) in
                self.imgScrollView.display(image: img)
                self.imgScrollView.alpha = 1
                self.postImgView.alpha = 0
                if img.size.width > 0 {
                    self.imgHeight.constant = screenWidth*(img.size.height/img.size.width)
                    self.tableView.reloadData()
                    self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
                    self.imgScrollView.refresh()
                    self.view.layoutIfNeeded()
                    self.tableView.reloadData()
                    self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                } else {
                    self.imgHeight.constant = screenWidth*(4/3.3)
                    self.tableView.reloadData()
                    self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
                    self.imgScrollView.refresh()
                    self.view.layoutIfNeeded()
                    self.tableView.reloadData()
                    self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
//                self.imgHeight.constant = screenWidth*(img.size.height/img.size.width)
//                self.tableView.reloadData()
//                self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
//                self.imgScrollView.refresh()
//                self.view.layoutIfNeeded()
//                self.tableView.reloadData()
//                self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//                Timer.schedule(delay: 0.2) { (t) in
//                    self.imgHeight.constant = screenWidth*(img.size.height/img.size.width)
//                    self.tableView.reloadData()
//                    self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
//                    self.imgScrollView.adjustFrameToCenter()
//                    self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//                }
            }
        }
        if let vid = media.videoUrl {
            if let video = URL(string: vid) {
                self.volumeBtn.alpha = 1
                self.videoPlayer.post = post
                self.dateLbl.text = "\(post.createdAtText())  •  \(post.viewCount!.countText(text: "view"))"
                self.setVideoPlayer(url: video)
            }
        }
        self.addTapGestures()
        self.textView.text = ""
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets(top: 14, left: 11, bottom: 11, right: 11)
        self.textView.placeholder = self.placeholder
        self.textView.placeholderColor = UIColor.lightGray
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
        self.postBtnWidthConstraint.constant = 0
        self.hideKeyboardWhenViewTapped(v: self.tableView)
//        self.imgScrollView.
        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    func setFollow(user: BMUser) {
//        guard let authUser = BMUser.me() else { return }
        if user.identifier == BMUser.me()?.identifier {
            self.followBtn.alpha = 0
            self.followBtn.setTitle("", for: [])
        } else {
            self.followBtn.alpha = 1
            if BMUser.me()?.checkFollow(user: user) ?? false {
                self.followBtn.setTitle("•  Following", for: [])
            } else {
                self.followBtn.setTitle("•  Follow", for: [])
            }
        }
    }
    
    @IBAction func tappedFollow() {
        guard let user = BMUser.me() else { return }
        addHaptic(style: .medium)
        user.followUser(user: self.post.user)
        self.setFollow(user: self.post.user)
        BMUser.save(user: &self.post.user)
//        ProfileService.make().followUser(user: self.post!.user!) { (response, u) in
//            BMUser.save(user: &ProfileService.make().user!)
//        }
    }

    
    @objc func showInfo() {
        if tap2.state == .ended {
            self.view.endEditing(true)
            if self.usernameLbl.alpha < 1 {
                self.showData(1)
            } else {
                self.showData(0)
            }
        }
    }
    
    @IBAction func nextMedia(_ sender: Any) {
        if self.pageControl.currentPage < self.post!.medias.count - 1 {
            let media = post.medias[self.pageControl.currentPage + 1]
            if let image = media.image {
                self.postImgView.image = image
            } else if let imgURL = media.imageUrl {
                self.pageControl.currentPage += 1
                self.postImgView.setImage(string: imgURL, duration: 0) { (img) in
                    self.imgScrollView.display(image: img)
                    let transition = CATransition()
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromRight
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    self.imgScrollView.layer.add(transition, forKey: nil)
                    self.imgHeight.constant = screenWidth*(img.size.height/img.size.width)
                    self.tableView.reloadData()
//                    self.imgScrollView.refresh()
//                    self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    UIView.animate(withDuration: 0.25) {
                        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
                        self.view.layoutIfNeeded()
                        self.tableView.reloadData()
//                        self.imgScrollView.refresh()
//                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
                    Timer.schedule(delay: 0.01) { (t) in
                        self.imgScrollView.refresh()
                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
                }
            }
        } else {
            print("no more medias to show")
        }
    }
    
    @IBAction func prevMedia(_ sender: Any) {
        if self.pageControl.currentPage > 0 {
            let media = post.medias[self.pageControl.currentPage - 1]
            if let image = media.image {
                self.postImgView.image = image
            } else if let imgURL = media.imageUrl {
                self.pageControl.currentPage == self.pageControl.currentPage - 1
                self.postImgView.setImage(string: imgURL, duration: 0) { (img) in
                    self.imgScrollView.display(image: img)
                    let transition = CATransition()
                    transition.type = CATransitionType.moveIn
                    transition.subtype = CATransitionSubtype.fromLeft
                    transition.duration = 0.25
                    transition.timingFunction = CAMediaTimingFunction(name: .easeOut)
                    self.imgScrollView.layer.add(transition, forKey: nil)
                    self.imgHeight.constant = screenWidth*(img.size.height/img.size.width)
//                    self.imgScrollView.refresh()
//                    self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    self.tableView.reloadData()
                    
                    UIView.animate(withDuration: 0.25) {
                        self.tableView.sizeHeaderToFit(preferredWidth: screenWidth)
                        self.view.layoutIfNeeded()
                        self.tableView.reloadData()
                        
//                        self.imgScrollView.refresh()
//                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
                    Timer.schedule(delay: 0.01) { (t) in
                        self.imgScrollView.refresh()
                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
                }
            }
        } else {
            print("no more medias to show")
        }
    }
    
    @IBAction func expandCommentTextView() {
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func changeVol(_ sender: Any) {
        addHaptic(style: .light)
        self.mutePlayer()
    }
    
    func setVideoPlayer(url: URL) {
        self.videoPlayer.alpha = 1
        if let p = self.videoPlayer.currentItem() {
            self.videoPlayer.start()
        } else {
            self.videoPlayer.play(url)
        }
    }
    
    func addTapGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedUserAvatar))
        self.userAvatar.isUserInteractionEnabled = true
        self.userAvatar.addGestureRecognizer(tap)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.likePostAction))
//        doubleTap.delaysTouchesBegan = true
//        doubleTap.delaysTouchesEnded = true
        doubleTap.numberOfTapsRequired = 2
        self.tableView.tableHeaderView!.addGestureRecognizer(doubleTap)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showInfo))
//        let tap2 = UILongPressGestureRecognizer(target: self, action: #selector(self.showInfo))
        tap2.addTarget(self, action: #selector(self.showInfo))
        tap2.minimumPressDuration = 0.2
        tap2.allowableMovement = 0
//        tap2.state == .ended {
//
//        }
//        tap2.reset()
//        tap1.delaysTouchesBegan = true
//        tap1.delaysTouchesEnded = true
//        tap1.requiresExclusiveTouchType = true
//        tap1.canBePrevented(by: doubleTap)
        self.tableView.tableHeaderView!.addGestureRecognizer(tap2)
        self.tableView.tableHeaderView!.addGestureRecognizer(doubleTap)
        self.tableView.tableHeaderView!.isUserInteractionEnabled = true
        self.addMuteGesture()
    }
    
    func addMuteGesture() {
//        let press = UITapGestureRecognizer(target: self, action: #selector(self.mutePlayer))
//        press.cancelsTouchesInView = false
//        self.videoPlayer.addGestureRecognizer(press)
//        self.videoPlayer.isUserInteractionEnabled = true
    }
    
    @objc func mutePlayer() {
        if self.textView.isFirstResponder {
            self.view.endEditing(true)
        } else {
            if let p = self.videoPlayer.getPlayer() {
                if p.isMuted {
                    p.isMuted = false
                    self.volumeBtn.setImage(.get(name: "volumeonicon", tint: UIColor.white.withAlphaComponent(0.8)), for: [])
                } else {
                    p.isMuted = true
                    self.volumeBtn.setImage(.get(name: "volumeofficon", tint: UIColor.white.withAlphaComponent(0.8)), for: [])
                }
            }
        }
    }
    
    @objc func tappedUserAvatar() {
        //go to user profile
        if let d = self.delegate {
            d.tappedProfile(user: self.post!.user!)
        }
    }
    
    @IBAction func tappedLikeBtn(_ sender: Any) {
        likePostAction()
    }
    
    @objc func likePostAction() {
//        BMPostService.make().getLikes(post: self.post!) { (response, users) in
//            var u = [BMUser]()
//            u = users
//            if users.count == 0 {
//                var me = BMUser.me()
//                me.username = "Be the first like"
//                u.append(me)
//            }
//            self.showUserList(users: u)
//        }light)
        addHaptic(style: .light)
        //to remove any time delay in changing icons due to network
//        if self.likeBtn.tintColor == .white {
//            self.checkLikeBtn(fill: true)
//            self.post!.likeCount! += 1
//            BMPost.save(post: &self.post!)
//        } else {
//            self.post!.likeCount! = self.post!.likeCount! - 1
//            BMPost.save(post: &self.post!)
//        }
        if self.likeBtn.tintColor == .white {
            self.checkLikeBtn(fill: true)
            self.post!.likeCount! += 1
            BMPost.save(post: &self.post!)
            self.likeCountLbl.text = "\(self.post!.likeCount!)"
            self.likeBtn.setImage(.get(name: "heartfill", tint: .systemRed), for: [])
            self.likeBtn.tintColor = .systemRed
            let l = BMPostLike(post: self.post!)
    //        ProfileService.make().user!.postLikes.append(l)
      //      BMUser.save(user: &ProfileService.make().user!)
        } else {
            self.post?.likeCount? -= 1 // self.post!.likeCount! - 1
            BMPost.save(post: &self.post!)
            self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
            self.likeBtn.tintColor = .white
            self.likeCountLbl.text = "\(self.post!.likeCount!)"
//            if let ind = me.postLikes.firstIndex(where: {$0.postId ?? UInt(555555) == self.post!.id!}) {
//                me.postLikes.remove(at: ind)
//            }
        }
        
        BMPostService.make().likePost(post: self.post!) { (response, u) in
            if let user = u {
//                ProfileService.make().user = user
//                self.checkLikeBtn()
            }
        }
    }
    
    func checkLikeBtn(fill: Bool = false) {
        self.likeCountLbl.text = "\(self.post!.likeCount!)"
        if BMUser.me()?.checkLike(post: self.post!) ?? false || fill == true {
//            self.likeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))!, for: [])
            self.likeBtn.setImage(.get(name: "heartfill", tint: .systemRed), for: [])
            self.likeBtn.tintColor = .systemRed
        } else {
//            self.likeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))!, for: [])
            self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
            self.likeBtn.tintColor = .white
        }
    }
    
    @IBAction func commentsRelatedSwitch(_ sender: UIButton) {
        addHaptic(style: .light)
        if sender == self.commentsBtn {
            self.commentsBtn.setTitleColor(.label, for: [])
            self.relatedBtn.setTitleColor(.systemGray2, for: [])
            self.switchComments(showRelated: false)
            self.showingRelated = false
            self.tableView.reloadData()
        } else {
            self.commentsBtn.setTitleColor(.systemGray2, for: [])
            self.relatedBtn.setTitleColor(.label, for: [])
            self.switchComments(showRelated: true)
            self.showingRelated = true
            self.tableView.reloadData()
            let sep = self.post!.caption!.components(separatedBy: " ")
            var search = ""
            if let l = self.post!.location {
                search = l
            }
            if let c = self.post!.category {
                search = c.title!
            }
            for i in sep {
                if i.hasPrefix("#") {
                    search = i
                }
            }
            BMPostService.make().getRelated(post: self.post!, search: search, count: 8) { (response, related) in
                let r = related.removeDuplicates()
                self.relatedPosts = r.filter({$0.id! != self.post!.id!})
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func showPostMenu() {
        getMenu(post: self.post!, vc: self.navigationController, completion: {
         //   BMUser.save(user: &ProfileService.make().user!)
            if let d = self.pagingDelegate {
                print("updating new post")
                d.viewedNewPost(post: self.post!)
            }
        })
    }
    
    func switchComments(showRelated: Bool) {
        if showRelated {
            print("should show related")
            self.textContainerBottomConstraint.constant = -150
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            print("should show comments")
            if self.textContainerBottomConstraint.constant != -34 {
                self.textContainerBottomConstraint.constant = -34
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayer.pause()
        self.showData(1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoPlayer.pause()
        self.videoPlayer.playOnLoad = false
        self.showData(1)
    }
    
    @IBAction func addPost(_ sender: UIButton) {
        guard let user = BMUser.me() else { return }
        addHaptic(style: .medium)
        if let comment = self.commentForReply {
            let reply = BMPostSubComment(user: user, message: self.textView.text!)
            if let index = self.post!.comments.index(of: comment) {
                self.post!.comments[index].replies.append(reply)
                self.post!.comments[index].replyCount.append(1)
                self.tableView.reloadData()
                self.textView.text = ""
                self.postBtnWidthConstraint.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
                self.view.endEditing(true)
                self.commentForReply = nil
                if let s = self.subCommentForReply {
                    self.subCommentForReply = nil
                    BMPostService.make().addReply(comment: comment, reply: reply, sub: s) { (response) in
                        print("added reply to ANOTHER REPLY!!!")
                    }
                } else {
                    BMPostService.make().addReply(comment: comment, reply: reply) { (response) in
                        print("added reply to comment!!!")
                    }
                }
            }
        } else {
            let comment = BMPostComment(user: user, message: self.textView.text!)
            self.post!.comments.append(comment)
            self.post!.commentCount! += 1
            self.tableView.reloadData()
            self.textView.text = ""
            self.postBtnWidthConstraint.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            self.view.endEditing(true)
            BMPostService.make().addComment(post: self.post!, comment: comment) { (response) in
                print("added comment to post!!!")
                self.commentCountLbl.text = "\(self.post!.commentCount!)"
            }
        }
    }
    
}

extension PostCommentViewController: VideoViewDelegate {
    func addViewCount(post: BMPost?) {
//        self.dateLbl.text = "\(post.createdAtText())  •  \(post.viewCount!.countText(text: "view"))"
        if var p = post {
            if p.user!.identifier != BMUser.me()?.identifier {
                p.viewCount += 1
                print("increased view count to: \(p.viewCount!.countText(text: "view"))")
                self.dateLbl.text = "\(p.createdAtText())  •  \(p.viewCount!.countText(text: "view"))"
                BMPost.save(post: &p)
                BMPostService.make().viewPost(post: p) { (response) in
                    print("updated view count to: ", p.viewCount!)
                }
            }
        }
    }
}

extension PostCommentViewController: ExpandingTableViewDataSource {

    func tableView(_ tableView: ExpandingTableView, expandableCellForSection section: Int) -> UITableViewCell {
        if self.showingRelated == false && self.post!.comments.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentTableViewCell", for: IndexPath(row: 0, section: section)) as! PostCommentTableViewCell
            cell.setNoComments()
            return cell
        }
        if self.showingRelated {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedPostsTableViewCell", for: IndexPath(row: 0, section: section)) as! RelatedPostsTableViewCell
            cell.collectionView.delegate = self
            cell.collectionView.dataSource = self
            cell.collectionView.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentTableViewCell", for: IndexPath(row: 0, section: section)) as! PostCommentTableViewCell
            cell.delegate = self
            cell.setComment(comment: self.post!.comments[section])
            return cell
        }
    }
    
    func tableView(_ tableView: ExpandingTableView, canExpandSection section: Int) -> Bool {
        return !self.showingRelated
    }
}
extension PostCommentViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.showingRelated == false && self.post!.comments.isEmpty {
            return 1
        }
        return self.showingRelated == true ? 1 : self.post!.comments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.showingRelated == false && self.post!.comments.isEmpty {
            return 1
        }
        if self.showingRelated == true {
            return 1
        } else if !self.post!.comments[section].replyCount.isEmpty {
            return self.post!.comments[section].replyCount.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.showingRelated == false && self.post!.comments.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentTableViewCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! PostCommentTableViewCell
//            cell.delegate = self
//            cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row], leading: 40)
            cell.setNoComments()
            return cell
        }
        switch indexPath.row {
        
        case 0:
            if self.showingRelated {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedPostsTableViewCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! RelatedPostsTableViewCell
                cell.collectionView.delegate = self
                cell.collectionView.dataSource = self
                cell.collectionView.reloadData()
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentTableViewCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! PostCommentTableViewCell
                cell.delegate = self
                cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row], leading: 40)
                cell.comment = self.post!.comments[indexPath.section]
                return cell
            }
        default:
            //this is where sub comment stuff goes
//            IndexPath(row: indexPath.row, section: indexPath.section)
//            let ind = IndexPath(row: indexPath.row, section: indexPath.section)
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCommentTableViewCell", for: indexPath) as! PostCommentTableViewCell
            cell.delegate = self
//            if indexPath.section < self.post!.comments.count {
//                if indexPath.row < self.post!.comments[indexPath.section].replies.count {
//                    cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row - 1], leading: 40)
//                }
//            }
//            if indexPath.row < self.post!.comments[indexPath.section].replies.count {
//                cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row - 1], leading: 40)
//            }
            if self.showingRelated {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedPostsTableViewCell", for: IndexPath(row: indexPath.row, section: indexPath.section)) as! RelatedPostsTableViewCell
//                cell.collectionView.delegate = self
//                cell.collectionView.dataSource = self
//                cell.collectionView.reloadData()
//                return cell
            } else {
                if indexPath.row == 0 {
                    cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row], leading: 40)
                    cell.comment = self.post!.comments[indexPath.section]
                } else {
                    if !self.post!.comments[indexPath.section].replies.isEmpty {
                        cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row - 1], leading: 40)
                        cell.comment = self.post!.comments[indexPath.section]
                    }
                }
            }
//            if ind.row == 0 {
//                cell.setSubComment(subComment: self.post!.comments[ind.section].replies[ind.row], leading: 40)
//            } else {
//                cell.setSubComment(subComment: self.post!.comments[ind.section].replies[ind.row - 1], leading: 40)
//            }
//            cell.setSubComment(subComment: self.post!.comments[ind.section].replies[ind.row - 1], leading: 40)
//            cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row - 1], leading: 40)
//            cell.setSubComment(subComment: self.post!.comments[indexPath.section].replies[indexPath.row - 1], leading: 40)
            return cell
        }
    }
}

extension PostCommentViewController: ExpandingTableViewDelegate {
    
    func didScroll(contentOffset: CGFloat) {
//        print("did scroll: ", contentOffset)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        print("DID SELECT row: \(indexPath.row), section: \(indexPath.section)")
    }
    
    func tableView(_ tableView: ExpandingTableView, expandingState state: ExpandingState, changeForSection section: Int) {
        print("Current state: \(state)")
    }
}

extension PostCommentViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if !self.textView.text!.replacingOccurrences(of: " ", with: "").isEmpty {
            self.postBtnWidthConstraint.constant = 50
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        } else {
            if self.postBtnWidthConstraint.constant != 0 {
                self.postBtnWidthConstraint.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.textView.text! == "" {
            self.textView.text = ""
        }
//        self.tableView.contentSize.height += 300
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.textView.text! == "" {
            self.textView.text = ""
        }
        if self.commentForReply != nil {
            self.textView.text = ""
            self.commentForReply = nil
        }
//        self.tableView.contentSize.height = self.tableView.contentSize.height - 300
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.textContainerBottomConstraint.constant = keyboardSize.height - 45
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = -keyboardSize.height
//                self.tableView.contentSize.height += 300
                self.view.layoutIfNeeded()
//                self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.post!.comments.count - 1), at: .middle, animated: true)
                self.tableView.scrollToBottom()
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.textContainerBottomConstraint.constant != -34 {
            self.textContainerBottomConstraint.constant = -34
            UIView.animate(withDuration: 0.25) {
                self.tableView.frame.origin.y = 0
                self.view.layoutIfNeeded()
                self.textView.placeholder = self.placeholder
//                self.tableView.contentSize.height = self.tableView.contentSize.height - 300
//                self.tableView.setContentOffset(.zero, animated: true)
                self.tableView.scrollToTop()
            }
        }
    }

}



extension PostCommentViewController: PostCellDelegate {
    func expandCell(cell: PostCommentTableViewCell, comment: BMPostComment, expand: Bool) {
        if expand == true {
            BMPostService.make().getReplies(comment: comment) { (response, replies) in
//                if let index = self.post!.comments.first(where: {$0.id! == comment.id!}) {
//                    self.post!.comments[index].replies = replies
//                    self.post!.comments[index].showReplies = true
//                    self.tableView.reloadData()
//                    self.tableView.expand(index)
//                }
                if let index = self.post!.comments.index(of: comment) {
                    self.post!.comments[index].replies = replies
                    self.post!.comments[index].showReplies = true
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        if let ind = self.tableView.indexPath(for: cell)?.section {
                            print("FOUND IND: ", ind)
                            self.tableView.expand(ind)
                        } else {
                            self.tableView.expand(index)
                        }
                    }
                }
            }
        } else {
            if let index = self.post!.comments.index(of: comment) {
                self.post!.comments[index].showReplies = false
                self.tableView.collapse(index)
                self.tableView.reloadData()
                self.tableView.collapse(index)
            }
        }
    }
    
    func addReply(comment: BMPostComment, reply: BMPostSubComment?) {
        self.commentForReply = comment
        self.textView.placeholder = "Replying to \(comment.user!.username!)..."
        if let s = reply {
            self.subCommentForReply = s
            self.textView.placeholder = "Replying to \(s.user!.username!)..."
        }
        self.textView.becomeFirstResponder()
    }
    
    func tappedUser(user: BMUser) {
        if let d = self.delegate {
            d.tappedProfile(user: user)
        }
    }

}

extension PostCommentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.relatedPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedPostCell", for: indexPath) as! RelatedPostCell
        cell.setPost(post: self.relatedPosts[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let posts = self.relatedPosts
        let vc = PostPageViewController.makeVC(post: self.relatedPosts[indexPath.item], otherPosts: posts)
        self.push(vc: vc)
    }
    
}

extension PostCommentViewController: ImageScrollViewDelegate {
    
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
        if scrollView == self.imgScrollView {
            if self.imgScrollView.zoomView!.frame.size.width <= screenWidth {
                self.showData(1)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
        if scrollView == self.imgScrollView || scrollView == self.tableView {
            let x = scrollView.contentOffset.x
            let y = scrollView.contentOffset.y
            if self.imgScrollView.zoomView != nil {
    //            if self.imgScrollView.zoomView!.frame.size.width < screenWidth {
                if self.imgScrollView.frame.origin.y != 0 && self.imgScrollView.zoomScale != self.imgScrollView.minimumZoomScale {
                    scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
                    self.imgScrollView.zoomView!.frame.origin.y = 0
                } else {
                    if self.imgScrollView.contentOffset.x == 0 && self.imgScrollView.contentOffset.y < 0 {
                        self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }
    //                self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            }
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        self.showData(0)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.imgScrollView {
            self.showData(0)
//            if self.imgScrollView.zoomView!.frame.size.width >= screenWidth - 4 {
//                self.imgScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.imgScrollView {
            if self.imgScrollView.zoomView!.frame.size.width <= screenWidth {
                self.showData(1)
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.imgScrollView {
            if self.imgScrollView.zoomView!.frame.size.width <= screenWidth {
                self.showData(1)
            }
        }
    }
    
    func showData(_ alpha: CGFloat) {
        if self.userAvatar.alpha != alpha {
            UIView.animate(withDuration: 0.2) {
                self.userAvatar.alpha = alpha
                self.menuBtn.alpha = alpha
                self.followBtn.alpha = self.post.user.identifier != BMUser.me()?.identifier ? alpha : 0
                self.usernameLbl.alpha = alpha
                self.captionLbl.alpha = alpha
                self.gradientView.alpha = alpha
                self.volumeBtn.alpha = self.post!.medias.first!.videoUrl != nil ? alpha : 0
                self.likeBtn.alpha = alpha
                self.likeCountLbl.alpha = alpha
                self.commentBtn.alpha = alpha
                self.commentCountLbl.alpha = alpha
                self.dateLbl.alpha = alpha
                self.navigationController?.navigationBar.alpha = alpha
            }
        }
    }
}
