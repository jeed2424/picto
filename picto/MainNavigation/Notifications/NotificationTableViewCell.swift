////
////  NotificationTableViewCell.swift
////  Warbly
////
////  Created by Knox Dobbins on 3/23/21.
////  Copyright © 2021 Warbly. All rights reserved.
////
//
//import Foundation
//import UIKit
//

import UIKit
class NotificationTableViewCell: UITableViewCell {
}
//
//    @IBOutlet weak var avatar: UIImageView!
//    @IBOutlet weak var lbl: UILabel!
//    
//    var notification: BMNotification!
//    var conversation: BMConversation!
//    
//    func setNoti(noti: BMNotification!) {
//        self.notification = noti
//        self.avatar.setImage(string: noti.user!.avatar!)
//        self.avatar.round()
//        let text = noti.body!.replacingOccurrences(of: noti.user!.username!, with: "")
//        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.bold, 15), .kern: 0.1]
//        let secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray, .font: BaseFont.get(.regular, 15)]
//        let dateAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray, .font: BaseFont.get(.medium, 15), .kern: 0.1]
//
//        let attrString = NSMutableAttributedString(string: "\(noti.user!.username!) ", attributes: firstAttributes)
//        let secondString = NSAttributedString(string: "\(text) ", attributes: secondAttributes)
//        let dateString = NSAttributedString(string: " \(noti.createdAtText())", attributes: dateAttributes)
//
//        attrString.append(secondString)
//        attrString.append(dateString)
//        
//        self.lbl.attributedText = attrString
//    }
//    
//    func setConvo(convo: BMConversation) {
//        self.conversation = convo
//        var firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.semiBold, 16.5), .kern: 0.1]
//        var secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGray.withAlphaComponent(0.9), .font: BaseFont.get(.regular, 15.5)]
//        let second1Attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray, .font: BaseFont.get(.regular, 6)]
//        var dateAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemGray, .font: BaseFont.get(.medium, 15), .kern: 0.1]
//
//        var attrString = NSMutableAttributedString(string: "\(convo.sender!.username!)\n", attributes: firstAttributes)
//        var t = "Send a message"
//        if let m = convo.lastMessage {
//            t = m.body!
//            if m.unread! == true && m.senderId! != me.id! {
//                firstAttributes = [.foregroundColor: UIColor.label, .font: BaseFont.get(.heavy, 17.5), .kern: 0.1]
//                secondAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label, .font: BaseFont.get(.medium, 16)]
//                dateAttributes = [.foregroundColor: UIColor.systemGray, .font: BaseFont.get(.medium, 15), .kern: 0.1]
//            }
//        }
//        var second1String = NSAttributedString(string: "\n", attributes: second1Attributes)
//        var secondString = NSAttributedString(string: t, attributes: secondAttributes)
//        var dateString = NSAttributedString(string: "  \(convo.createdAtText())", attributes: dateAttributes)
//        if convo.sender!.id! == me.id! {
//            self.avatar.setImage(string: convo.receiver!.avatar!)
//            attrString = NSMutableAttributedString(string: "\(convo.receiver!.username!)\n", attributes: firstAttributes)
//        } else {
//            self.avatar.setImage(string: convo.sender!.avatar!)
//        }
//        self.avatar.round()
//
//        attrString.append(second1String)
//        attrString.append(secondString)
//        attrString.append(dateString)
//        
//        self.lbl.attributedText = attrString
//    }
//}
//
class ReceiverMessageCell: UITableViewCell {
}
//
//    @IBOutlet weak var avatar: UIImageView!
//    @IBOutlet weak var messageLbl: UITextView!
//    @IBOutlet weak var dateLbl: UILabel!
//    @IBOutlet weak var dateHeight: NSLayoutConstraint!
//    
//    var conversation: BMConversation!
//    var message: BMMessage!
//    
//    func setMessage(message: BMMessage) {
//        if let m = self.conversation!.lastMessage {
//            if message == m && (message == self.conversation!.messages.last! && message.body! == self.conversation!.messages.last!.body!) {
//                self.dateHeight.constant = 28
//                self.dateLbl.text = message.createdAtText()
////                if message.unread! == false {
////                    self.dateLbl.text = "Seen • \(message.createdAtText())"
////                }
//            } else {
//                self.dateHeight.constant = 0
//                self.dateLbl.text = ""
//            }
//        } else {
//            self.dateHeight.constant = 0
//            self.dateLbl.text = ""
//        }
//        
//        self.layoutIfNeeded()
//        if message.senderId! == self.conversation!.sender!.id! {
//            self.avatar.setImage(string: self.conversation!.sender!.avatar!)
//        } else {
//            self.avatar.setImage(string: self.conversation!.receiver!.avatar!)
//        }
//        self.avatar.round()
//        self.messageLbl.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.label, .font: BaseFont.get(.regular, 17), .kern: 0.1]
//        let attrString = NSMutableAttributedString(string: message.body!, attributes: firstAttributes)
//        self.messageLbl.attributedText = attrString
//    }
//}
//
class SenderMessageCell: UITableViewCell {
}
//
//    @IBOutlet weak var messageLbl: UITextView!
//    @IBOutlet weak var dateLbl: UILabel!
//    @IBOutlet weak var dateHeight: NSLayoutConstraint!
//    
//    var conversation: BMConversation!
//    var message: BMMessage!
//    
//    func setMessage(message: BMMessage) {
//        if let m = self.conversation!.lastMessage {
//            if message == m && (message == self.conversation!.messages.last! && message.body! == self.conversation!.messages.last!.body!) {
//                self.dateHeight.constant = 28
//                self.dateLbl.text = message.createdAtText()
//                if message.unread! == false {
//                    self.dateLbl.text = "Seen • \(message.createdAtText())"
//                }
//            } else {
//                self.dateHeight.constant = 0
//                self.dateLbl.text = ""
//            }
//        } else {
//            self.dateHeight.constant = 0
//            self.dateLbl.text = ""
//        }
//        self.layoutIfNeeded()
//        self.messageLbl.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        let firstAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white, .font: BaseFont.get(.regular, 17), .kern: 0.1]
//        let attrString = NSMutableAttributedString(string: message.body!, attributes: firstAttributes)
//        self.messageLbl.attributedText = attrString
//    }
//}
