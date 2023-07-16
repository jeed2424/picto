//
//  CardCollectionViewCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/9/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import VerticalCardSwiper
import AVKit
import AVFoundation

protocol FeedCardDelegate {
    func tappedUser(post: BMPost)
    func showMenu(post: BMPost)
}

protocol VideoViewDelegate {
    func addViewCount(post: BMPost?)
}

class CardCollectionViewCell: CardCell {

    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var gradientView: UIView! {
        didSet {
            gradientView.roundCorners([.bottomLeft, .bottomRight], radius: 12)
        }
    }
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var captionLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet private weak var videoPlayer: PlayerView! {
        didSet {
            videoPlayer.playerLayer.videoGravity = .resizeAspectFill
            videoPlayer.videoViewDelegate = self
            videoPlayer.pause()
        }
    }
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var lblHeight: NSLayoutConstraint!
    
    var post: BMPost!
    var feedItem: FeedItem!
    var feedDelegate: FeedCardDelegate?
    var nav: UINavigationController?
    var fromCat = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestures()
        self.layer.borderWidth = 0.15
        self.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.videoPlayer.alpha = 0
        self.dateLbl.text = ""
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        super.layoutSubviews()
        self.gradientView.applyGradient(colors: [UIColor.black.withAlphaComponent(0.0), UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.7)], type: .vertical)
        self.gradientView.layer.cornerCurve = .continuous
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
        self.postImgView.layer.cornerCurve = .continuous
    }
    
    func setFeedItem(item: FeedItem) {
        self.feedItem = item
        self.videoPlayer.alpha = 0
        self.gradientView.layer.cornerCurve = .continuous
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
        self.userAvatar.setImage(string: item.user!.avatarURL!)
        self.userAvatar.round()
        self.usernameLbl.text = item.user!.username!
        self.usernameLbl.textDropShadow()
        self.captionLbl.text = item.caption!.removeTags()
        self.captionLbl.textDropShadow()
        self.dateLbl.text = item.createdAtText()
        self.likeCountLbl.text = "\(self.feedItem!.likeCount)"
        self.commentCountLbl.text = "\(self.feedItem!.commentCount)"
        
        //check whether image was generated from mock data or was uploaded from swifty cam
        if let imgURL = item.imageURL {
            self.postImgView.setImage(string: imgURL)
        } else {
            self.postImgView.image = item.image ?? UIImage()
        }
        
        //check if feed item has video
        if let video = item.videoURL {
            self.videoPlayer.feedItem = self.feedItem!
            self.setVideoPlayer(url: video)
        }
    }
    
    func setFeedItem(post: BMPost) {
//        for i 0..<self.gradientView.subviews.count {
//            self.gradientView.subviews
//        }
        self.gradientView.layer.layoutSublayers()
//        self.gradientView.applyGradient(colors: [UIColor.black.withAlphaComponent(0.0), UIColor.black.withAlphaComponent(0.1), UIColor.black.withAlphaComponent(0.7)], type: .vertical)
        self.videoPlayer.pause()
        self.captionLbl.text = post.caption!.removeTags()
        self.captionLbl.textDropShadow()
        if post.captionExpanded == true {
            self.lblHeight.constant = 300
        } else {
            var count = self.captionLbl.getLines()
            if count > 2 {
                count = 2
            }
            self.lblHeight.constant = CGFloat(count * 18)
//            self.lblHeight.constant = CGFloat(self.captionLbl.getLines() * 18)
//            if self.captionLbl.numberOfLines < 2 {
//                self.lblHeight.constant = self.captionLbl.numberOfLines * 20
//            } else {
//
//            }
//            self.lblHeight.constant = 35
        }
        self.gradientView.layer.cornerCurve = .continuous
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
        self.post = post
        self.setFollow(user: post.user)
        self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
        self.commentBtn.setImage(.get(name: "chatoutline", tint: .white), for: [])
        self.volumeBtn.setImage(.get(name: "volumeonicon", tint: UIColor.white.withAlphaComponent(0.8)), for: [])
        self.volumeBtn.alpha = 0
        self.likeBtn.tintColor = .white
        self.checkLikeBtn(fill: false)
        self.videoPlayer.alpha = 0
        self.userAvatar.setImage(string: post.user!.avatar!)
        self.userAvatar.round()
        self.usernameLbl.text = post.user!.username!
        self.usernameLbl.textDropShadow()
        self.captionLbl.text = post.caption!.removeTags()
        self.captionLbl.textDropShadow()
        self.dateLbl.text = post.createdAtText()
        self.likeCountLbl.text = "\(post.likeCount!)"
        self.commentCountLbl.text = "\(post.commentCount!)"
        
        if let media = post.medias.first {
        if let image = media.image {
            self.postImgView.image = image
            self.videoPlayer.setPlayerNil()
            self.dateLbl.text = post.createdAtText()
        } else if let imgURL = media.imageUrl {
            self.postImgView.setImage(string: imgURL)
            self.videoPlayer.setPlayerNil()
            self.dateLbl.text = post.createdAtText()
//            Timer.schedule(delay: 0.2) { (t) in
//                self.dateLbl.text = post.createdAtText()
//            }
        }
        if let vid = media.videoUrl {
            if let video = URL(string: vid) {
                self.videoPlayer.post = post
                self.setVideoPlayer(url: video)
                self.dateLbl.text = "\(post.createdAtText())  •  \(post.viewCount!.countText(text: "view"))"
            }
        }
        } else {
            print("\(post.medias.first)")
        }
    }
    
    func setVideoPlayer(url: URL) {
//        let temporaryFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("postmain_\(url.absoluteString.replacingOccurrences(of: "/storage.googleapis.com/emblem_creator_videos/", with: "").replacingOccurrences(of: "/firebasestorage.googleapis.com/v0/b/warbly-265ed.appspot.com/o/videos%", with: "").replacingOccurrences(of: "/", with: ""))")
//        let fileURL = URL(fileURLWithPath: temporaryFile)
//        if let i = UIImage.gifImageWithURL(fileURL.absoluteString) {
//            self.postImgView.image = i
//        } else {
//            DispatchQueue.main.async {
//                Regift.createGIFFromSource(url, destinationFileURL: fileURL, startTime: 0, duration: 0.2, frameRate: 2, loopCount: 1) { (result) in
//                    print("Gif saved to \(result)")
//                    let imageURL = UIImage.gifImageWithURL(result!.absoluteString)
//                    self.postImgView.image = imageURL!
//                }
//            }
//        }
        let media = post.medias.first!
        if let image = media.image {
            self.postImgView.image = image
        } else if let imgURL = media.imageUrl {
            self.postImgView.setImage(string: imgURL)
        }
        self.videoPlayer.alpha = 1
        self.volumeBtn.alpha = 1
        if let p = self.videoPlayer.currentItem() {
            self.videoPlayer.start()
        } else {
            self.videoPlayer.play(url)
        }
        
    }
    
    func play() {
        self.videoPlayer.start()
    }
    
    func pause() {
        self.videoPlayer.pause()
    }
    
    func setFollow(user: BMUser) {
        if user.id! == BMUser.me().id! {
            self.followBtn.alpha = 0
            self.followBtn.setTitle("", for: [])
        } else {
            self.followBtn.alpha = 0
            if BMUser.me().checkFollow(user: user) {
                self.followBtn.setTitle("•  Following", for: [])
            } else {
                self.followBtn.setTitle("•  Follow", for: [])
            }
        }
    }
    
    @IBAction func tappedFollow() {
        addHaptic(style: .medium)
        BMUser.me().followUser(user: self.post!.user!)
        self.setFollow(user: self.post!.user!)
        BMUser.save(user: &self.post!.user!)
//        ProfileService.make().followUser(user: self.post!.user!) { (response, u) in
//            BMUser.save(user: &ProfileService.make().user!)
//        }
    }
    
//    @objc func expandLbl() {
//        if self.post!.captionExpanded == true {
//            self.lblHeight.constant = 35
//            self.post!.captionExpanded = false
//        } else {
//            self.lblHeight.constant = 300
//            self.post!.captionExpanded = true
//        }
//        BMPost.save(post: &self.post!)
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
//            self.layoutIfNeeded()
//        } completion: { (t) in
//
//        }
//
//    }
    
    @IBAction func expandTheLbl() {
        if self.post!.captionExpanded == true {
//            self.lblHeight.constant = 35
            var count = self.captionLbl.getLines()
            if count > 2 {
                count = 2
            }
            self.lblHeight.constant = CGFloat(count * 18)
            self.post!.captionExpanded = false
        } else {
            self.lblHeight.constant = 300
            self.post!.captionExpanded = true
        }
        self.captionLbl.textDropShadow()
        BMPost.save(post: &self.post!)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear) {
            self.layoutIfNeeded()
        } completion: { (t) in
            
        }
    }
    
    func addTapGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedUserAvatar))
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tappedUserAvatar))
//        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.expandLbl))
//        tap2.requiresExclusiveTouchType = true
//        tap2.can
//        tap2.cancelsTouchesInView = true
//        tap.cancelsTouchesInView = true
//        tap1.cancelsTouchesInView = true
        self.userAvatar.isUserInteractionEnabled = true
        self.userAvatar.addGestureRecognizer(tap)
        self.usernameLbl.isUserInteractionEnabled = true
        self.usernameLbl.addGestureRecognizer(tap1)
        self.usernameLbl.textDropShadow()
//        self.captionLbl.isUserInteractionEnabled = true
//        self.captionLbl.addGestureRecognizer(tap2)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.likePostAction))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        self.isUserInteractionEnabled = true
        if self.fromCat == false {
            self.addPauseGesture()
        } else {
            self.gradientView.isUserInteractionEnabled = false
            self.postImgView.isUserInteractionEnabled = false
            self.videoPlayer.isUserInteractionEnabled = false
        }
    }
    
    func addPauseGesture() {
        let press = UITapGestureRecognizer(target: self, action: #selector(self.pausePlayer))
        press.cancelsTouchesInView = true
        self.addGestureRecognizer(press)
        self.isUserInteractionEnabled = true
    }
    
    @objc func pausePlayer() {
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
    
    @IBAction func changeVol(_ sender: Any) {
        self.pausePlayer()
    }
    
    @IBAction func addToCollection(_ sender: Any) {
        getMenu(post: self.post!, vc: self.nav) {
           // BMUser.save(user: &ProfileService.make().user!)
            self.setFeedItem(post: self.post!)
        }
    }
    
    @IBAction func showUserProf(_ sender: Any) {
        if let d = self.feedDelegate {
            addHaptic(style: .light)
            d.tappedUser(post: self.post!)
        }
    }
    
    
    @objc func tappedUserAvatar() {
        if let d = self.feedDelegate {
            addHaptic(style: .light)
            d.tappedUser(post: self.post!)
        }
    }
    
    @IBAction func tappedLikeBtn(_ sender: Any) {
        likePostAction()
    }
    
    @objc func likePostAction() {
        
        addHaptic(style: .success)
        
        //to remove any time delay in changing icons due to network
        if self.likeBtn.tintColor == .white {
            self.checkLikeBtn(fill: true)
            self.post!.likeCount! += 1
            BMPost.save(post: &self.post!)
            self.likeCountLbl.text = "\(self.post!.likeCount!)"
            self.likeBtn.setImage(.get(name: "heartfill", tint: .systemRed), for: [])
            self.likeBtn.tintColor = .systemRed
//            if me.checkLike(post: post) == true {
//                if let ind = me.postLikes.firstIndex(where: {$0.postId ?? UInt(555555) == post.id!}) {
//                    me.postLikes.remove(at: ind)
//                }
//            } else {
//                let l = BMPostLike(post: post)
//                me.postLikes.append(l)
//            }
            let l = BMPostLike(post: self.post!)
//            ProfileService.make().user!.postLikes.append(l)
//            BMUser.save(user: &ProfileService.make().user!)
        } else {
            self.post?.likeCount? -= 1 // self.post!.likeCount! - 1
            BMPost.save(post: &self.post!)
            self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
            self.likeBtn.tintColor = .white
            self.likeCountLbl.text = "\(self.post!.likeCount!)"
            if let ind = me.postLikes.firstIndex(where: {$0.postId ?? UInt(555555) == self.post!.id!}) {
                me.postLikes.remove(at: ind)
            }
        }
        BMPostService.make().likePost(post: self.post!) { (response, u) in
            if let user = u {
//                ProfileService.make().user = user
//                self.checkLikeBtn()
            }
        }
    }
    
    func checkLikeBtn(fill: Bool = true) {
        self.likeCountLbl.text = "\(self.post!.likeCount!)"
        if BMUser.me().checkLike(post: self.post!) || fill == true {
            self.likeBtn.setImage(.get(name: "heartfill", tint: .systemRed), for: [])
            self.likeBtn.tintColor = .systemRed
        } else {
            self.likeBtn.setImage(.get(name: "heart", tint: .white), for: [])
            self.likeBtn.tintColor = .white
        }
    }
    

}

extension CardCollectionViewCell: VideoViewDelegate {
    func addViewCount(post: BMPost?) {
        if var p = post {
            if let video = URL(string: p.medias.first!.videoUrl ?? "") {
                if p.user!.id! != BMUser.me().id! && self.videoPlayer.currentItem() != nil {
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
}

//for video tap
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension UIImage {
    static func get(name: String, tint: UIColor = .white, size: CGFloat? = nil) -> UIImage {
        var i = UIImage(named: name)!.withTintColor(tint)
        if let s = size {
            return i.resizeImage(image: i, newWidth: s) ?? i
        }
        return i
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
