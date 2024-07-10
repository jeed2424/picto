//
//  PostCommentTableViewCell.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/15/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit

protocol PostCellDelegate {
    func expandCell(cell: PostCommentTableViewCell, comment: BMPostComment, expand: Bool)
    func addReply(comment: BMPostComment, reply: BMPostSubComment?)
    func tappedUser(user: BMUser)
}

class PostCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameReplyLbl: UITextView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var viewRepliesBtn: UIButton!
    @IBOutlet weak var repliesLine: UIView!
    @IBOutlet weak var avatarLeading: NSLayoutConstraint!
    @IBOutlet weak var commentLikeBtn: UIButton!
    
    @IBOutlet weak var viewRepliesHeight: NSLayoutConstraint!
    
    var delegate: PostCellDelegate?
    var comment: BMPostComment!
    var subComment: BMPostSubComment!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setNoComments(leading: CGFloat = 20) {
        self.avatarLeading.constant = leading
//        self.avatar.setImage(string: me.avatar!)
        self.avatar.round()
        self.usernameLbl.text = "Username appears here"
        self.usernameLbl.textColor = .clear
        self.setNoMessage()
        self.nameReplyLbl.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.dateLbl.text = ""
        self.likesBtn.setTitle("", for: [])
        self.viewRepliesBtn.alpha = 0
//        self.viewRepliesHeight.constant = 0
        self.repliesLine.alpha = 0
        self.replyBtn.alpha = 0
        self.likesBtn.alpha = 0
        self.commentLikeBtn.alpha = 0
//        self.addTaps()
    }
    
    func setComment(comment: BMPostComment, leading: CGFloat = 20) {
        self.viewRepliesBtn.alpha = 1
//        self.viewRepliesHeight.constant = 0
        self.repliesLine.alpha = 1
        self.replyBtn.alpha = 1
        self.likesBtn.alpha = 1
        self.commentLikeBtn.alpha = 1
        self.avatarLeading.constant = leading
        self.comment = comment
        self.setRepliesHeight(comment: comment)
        self.avatar.setImage(string: comment.user!.avatar!)
        self.avatar.round()
        self.usernameLbl.text = comment.user!.username!
        self.usernameLbl.textColor = .clear
        self.setMessage(comment: comment)
        self.nameReplyLbl.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.dateLbl.text = comment.createdAtText()
        self.likesBtn.setTitle(comment.likeCount.countText(text: "like"), for: [])
        self.checkCommentLike(comment: comment)
        self.addTaps()
    }
    
    func setRepliesHeight(comment: BMPostComment) {
        if !comment.replyCount.isEmpty && self.avatarLeading.constant == 20 {
            self.repliesLine.alpha = 1
            self.viewRepliesBtn.alpha = 1
            self.viewRepliesHeight.constant = 25
            if comment.showReplies == true {
                self.viewRepliesBtn.setTitle("          Hide replies", for: [])
            } else {
                if comment.replyCount.count == 1 {
                    self.viewRepliesBtn.setTitle("          View \(comment.replyCount.count) reply", for: [])
                } else {
                    self.viewRepliesBtn.setTitle("          View \(comment.replyCount.count) replies", for: [])
                }
            }
        } else {
            self.repliesLine.alpha = 0
            self.viewRepliesBtn.alpha = 0
            self.viewRepliesHeight.constant = 0
        }
    }

    func setMessage(comment: BMPostComment) {
        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.bold, 15), .kern: 0.2]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel, .font: BaseFont.get(.regular, 15)]

        let attrString = NSMutableAttributedString(string: "\(comment.user!.username!)", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "  \(comment.message!)", attributes: secondAttributes)

        attrString.append(secondString)
        
        self.nameReplyLbl.attributedText = attrString
    }
    
    func setNoMessage() {
        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.bold, 15), .kern: 0.2]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel, .font: BaseFont.get(.regular, 15)]

        let attrString = NSMutableAttributedString(string: "Username appears hhere", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "  Be the first to comment on this post!", attributes: secondAttributes)

        attrString.append(secondString)
        
        self.nameReplyLbl.attributedText = attrString
    }
    
    func checkCommentLike(comment: BMPostComment) {
        let me = BMUser.me()
        if comment.user!.id! == me.id! {
            self.commentLikeBtn.alpha = 0
            return
        }
        self.commentLikeBtn.alpha = 1
        if me.checkLike(comment: comment) {
            self.commentLikeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
            self.commentLikeBtn.tintColor = .systemRed
        } else {
            self.commentLikeBtn.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
            self.commentLikeBtn.tintColor = .systemGray
        }
    }
    
    
    //for subcomments aka replies
    func setSubComment(subComment: BMPostSubComment, leading: CGFloat = 20) {
        self.viewRepliesBtn.alpha = 1
        self.repliesLine.alpha = 1
        self.replyBtn.alpha = 1
        self.likesBtn.alpha = 1
        self.commentLikeBtn.alpha = 1
        self.avatarLeading.constant = leading
        self.subComment = subComment
        self.setRepliesHeight(subComment: subComment)
        self.avatar.setImage(string: subComment.user!.avatar!)
        self.avatar.round()
        self.usernameLbl.text = subComment.user!.username!
        self.usernameLbl.textColor = .clear
        self.setMessage(subComment: subComment)
        self.nameReplyLbl.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        self.dateLbl.text = subComment.createdAtText()
        self.likesBtn.setTitle(subComment.likeCount.countText(text: "like"), for: [])
        self.checkReplyLike(reply: subComment)
        self.addTaps()
    }
    
    func checkReplyLike(reply: BMPostSubComment) {
        let me = BMUser.me()
        if reply.user!.id! == me.id! {
            self.commentLikeBtn.alpha = 0
            return
        }
        self.commentLikeBtn.alpha = 1
        if me.checkLike(reply: reply) {
            self.commentLikeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
            self.commentLikeBtn.tintColor = .systemRed
        } else {
            self.commentLikeBtn.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
            self.commentLikeBtn.tintColor = .systemGray
        }
    }
    
    func addTaps() {
        let imgTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedProfile))
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(self.tappedProfile))
        avatar.isUserInteractionEnabled = true
        usernameLbl.isUserInteractionEnabled = true
        avatar.addGestureRecognizer(imgTap)
        usernameLbl.addGestureRecognizer(nameTap)
        self.contentView.bringSubviewToFront(self.usernameLbl)
    }
    
    @objc func tappedProfile() {
        addHaptic(style: .light)
        if let d = self.delegate {
            if let c = self.comment {
                d.tappedUser(user: c.user!)
            }
            if let s = self.subComment {
                d.tappedUser(user: s.user!)
            }
        }
    }
    
    func setRepliesHeight(subComment: BMPostSubComment) {
        self.repliesLine.alpha = 0
        self.viewRepliesBtn.alpha = 0
        self.viewRepliesHeight.constant = 0
    }

    func setMessage(subComment: BMPostSubComment) {
        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.bold, 15), .kern: 0.2]
        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel, .font: BaseFont.get(.regular, 15)]

        let attrString = NSMutableAttributedString(string: "\(subComment.user!.username!)", attributes: firstAttributes)
        let secondString = NSAttributedString(string: "  \(subComment.message!)", attributes: secondAttributes)

        attrString.append(secondString)
        
        self.nameReplyLbl.attributedText = attrString
    }
    
    @IBAction func expandCell(_ sender: Any) {
        if self.comment!.showReplies == false {
            self.viewRepliesBtn.setTitle("          Hide replies", for: [])
            if let d = self.delegate {
                d.expandCell(cell: self, comment: self.comment!, expand: true)
            }
        } else {
            self.viewRepliesBtn.setTitle("          View \(self.comment!.replyCount.count) reply", for: [])
            if let d = self.delegate {
                d.expandCell(cell: self, comment: self.comment!, expand: false)
            }
        }
    }
    
    @IBAction func addReply(_ sender: Any) {
        if let d = self.delegate {
            if let s = self.subComment {
                d.addReply(comment: self.comment!, reply: s)
            } else {
                d.addReply(comment: self.comment!, reply: nil)
            }
//            d.addReply(comment: self.comment!, reply: s)
        }
    }
    
    @IBAction func likeComment(_ sender: Any) {
        addHaptic(style: .light)
        let me = BMUser.me()
        if let reply = self.subComment {
            if me.checkLike(reply: reply) {
                self.commentLikeBtn.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
                self.commentLikeBtn.tintColor = .systemGray
                self.subComment!.likes = self.subComment!.likes! - 1
            } else {
                self.commentLikeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
                self.commentLikeBtn.tintColor = .systemRed
                self.subComment!.likes! += 1
            }
            self.likesBtn.setTitle(self.subComment!.likeCount.countText(text: "like"), for: [])
            BMPostService.make().likeReply(reply: reply) { (response, usr) in
                print("liked comment reply")
//                ProfileService.make().user = usr!
//                BMUser.save(user: &ProfileService.make().user!)
            }
            BMPostSubComment.save(comment: &self.subComment!)
        } else if let comm = self.comment {
            if me.checkLike(comment: comm) {
                self.commentLikeBtn.setImage(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
                self.commentLikeBtn.tintColor = .systemGray
                self.comment!.likes = self.comment!.likes! - 1
            } else {
                self.commentLikeBtn.setImage(UIImage(systemName: "heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))!, for: [])
                self.commentLikeBtn.tintColor = .systemRed
                self.comment!.likes! += 1
            }
            self.likesBtn.setTitle(self.comment!.likeCount.countText(text: "like"), for: [])
            BMPostService.make().likeComment(comment: comm) { (response, usr) in
                print("liked post comment")
              //  ProfileService.make().user = usr!
            }
        }
    }
}
