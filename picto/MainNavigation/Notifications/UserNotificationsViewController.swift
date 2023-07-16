//
//  UserNotificationsViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/18/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import UIKit
import PixelSDK

class UserNotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    static func makeVC() -> UserNotificationsViewController {
        let vc = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "UserNotificationsViewController") as! UserNotificationsViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setNavBar(title: "Notifications")
        refreshControl.addTarget(self, action: #selector(reloadNotis), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.contentInset.bottom = 120
        self.tableView.reloadData()
        self.extendedLayoutIncludesOpaqueBars = true
        tableView.contentInsetAdjustmentBehavior = .always
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar(title: "Notifications")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: "Notifications")
        self.tableView.fadeReload()
        self.removeRedDot(index: 2)
//        ProfileService.make().loadUser(user: BMUser.me()) { (response, u) in
//            if let usr = u {
//                ProfileService.make().user = usr
//                self.tableView.fadeReload()
//            }
//        }
    }
    
    @objc func reloadNotis() {
        self.tableView.refreshControl?.beginRefreshing()
        ProfileService.make().loadUser(user: BMUser.me()) { (response, u) in
            if let usr = u {
   //             ProfileService.make().user = usr
                self.tableView.reloadData()
                Timer.schedule(delay: 0.2) { (t) in
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    
    // Do all navigation setup here
    func setNavBar(title: String) {
        self.setNavTitle(text: title, font: BaseFont.get(.bold, 18), letterSpacing: 0.1, color: .label)
//        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
        self.setRightNavBtnInbox(hasUnread: me.unreadMessages() > 0 ? true : false, image: UIImage(named: "fi_send")!, color: .label, action: #selector(self.openDMs), animated: false)
        self.setInviteEmoji()
    }
    
    @objc func openDMs() {
        let vc = ConversationsViewController.makeVC()
        self.push(vc: vc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BMUser.me().notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.setNoti(noti: BMUser.me().notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let p = BMUser.me().notifications[indexPath.row].post {
            if let u = BMUser.me().notifications[indexPath.row].user {
                getNotiMenu(post: p, user: u, vc: self.navigationController) {
                    print("showing noti menu")
                }
            } else {
                let posts = BMUser.me().notifications[indexPath.row].user!.posts
                let vc = PostPageViewController.makeVC(post: p, otherPosts: posts)
                self.push(vc: vc)
            }
//            let posts = BMUser.me().notifications[indexPath.row].user!.posts
//            let vc = PostPageViewController.makeVC(post: p, otherPosts: posts)
//            self.push(vc: vc)
        } else if let u = BMUser.me().notifications[indexPath.row].user {
            let vc = UserProfileViewController.makeVC(user: u)
            vc.hidesBottomBarWhenPushed = true
            self.push(vc: vc)
        }
    }
}

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GalaMessageDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
//    var delegate: GalaMessageDelegate?
    
    static func makeVC() -> ConversationsViewController {
        let vc = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "ConversationsViewController") as! ConversationsViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setNavBar(title: "Inbox")
        refreshControl.addTarget(self, action: #selector(reloadNotis), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.contentInset.bottom = 120
        self.tableView.reloadData()
        self.extendedLayoutIncludesOpaqueBars = true
        tableView.contentInsetAdjustmentBehavior = .always
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadInNewMessage), name: NSNotification.Name("newMessageReceived"), object: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar(title: "Inbox")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar(title: "Inbox")
        self.tableView.fadeReload()
        self.removeRedDot(index: 2)
        ProfileService.make().loadConversations(user: BMUser.me()) { (response, convos) in
  //          ProfileService.make().user!.conversations = convos
            self.tableView.fadeReload()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadInNewMessage), name: NSNotification.Name("newMessageReceived"), object: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = true
    }
    
    @objc func loadInNewMessage() {
        print("DID UPDATE MESSAGE ON CONVOS PAGE")
        self.tableView.fadeReload()
//        self.tableView.scrollToBottom()
    }
    
    func didReceiveMessage(message: BMMessage) {
        print("DID UPDATE MESSAGE ON CONVOS PAGE: \(message.body!)")
        self.tableView.fadeReload()
//        self.tableView.scrollToBottom()
    }
    
    @objc func reloadNotis() {
        self.tableView.refreshControl?.beginRefreshing()
        ProfileService.make().loadConversations(user: BMUser.me()) { (response, convos) in
     //       ProfileService.make().user!.conversations = convos
            self.tableView.reloadData()
            Timer.schedule(delay: 0.2) { (t) in
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    // Do all navigation setup here
    func setNavBar(title: String) {
        self.setNavTitle(text: title, font: BaseFont.get(.bold, 18), letterSpacing: 0.1, color: .label)
//        self.setRightNavBtn(image: UIImage(named: "cameraadd")!, color: .label, action: #selector(self.openCamera), animated: false)
//        self.setInviteEmoji()
        self.setBackBtn(color: .label, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BMUser.me().conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.setConvo(convo: BMUser.me().conversations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let convo = BMUser.me().conversations[indexPath.row]
        var otherUser = convo.sender!
        if convo.sender!.id! == me.id! {
            otherUser = convo.receiver!
        }
        let vc = ConversationViewController.makeVC(convo: BMUser.me().conversations[indexPath.row], user: otherUser)
        self.push(vc: vc)
    }
}

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GalaMessageDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textContainerImg: UIImageView!
    @IBOutlet weak var textContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var postBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    
    var placeholder = "Send a message..."
    var refreshControl = UIRefreshControl()
    var conversation: BMConversation!
    var otherUser: BMUser!
//    var delegate: GalaMessageDelegate?
    
    static func makeVC(convo: BMConversation?, user: BMUser) -> ConversationViewController {
        let vc = UIStoryboard(name: "Notifications", bundle: nil).instantiateViewController(withIdentifier: "ConversationViewController") as! ConversationViewController
        vc.conversation = convo
        vc.otherUser = user
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.textView.text = ""
        self.textView.delegate = self
        self.textView.textContainerInset = UIEdgeInsets(top: 13, left: 16, bottom: 11, right: 11)
        self.textView.placeholder = self.placeholder
        self.textView.placeholderColor = UIColor.darkGray.withAlphaComponent(0.7)
        self.postBtnWidthConstraint.constant = 0
        self.hideKeyboardWhenViewTapped(v: self.tableView)
        self.setNavBar()
        refreshControl.addTarget(self, action: #selector(reloadNotis), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        tableView.contentInset.top = 25
//        tableView.contentInset.bottom = 120
//        self.tableView.hide(duration: 0)
        if let c = self.conversation {
            self.tableView.alpha = 0
            self.tableView.fadeReload()
            self.tableView.scrollToBottomNoAnim()
            
            if let m = self.conversation!.lastMessage {
                self.conversation!.lastMessage!.unread = false
                BMMessage.save(message: &self.conversation!.lastMessage!)
            }
            Timer.schedule(delay: 0.2) { (t) in
                self.tableView.show(duration: 0.2)
            }
            
            ConversationService.make().loadMessages(conversation: self.conversation!) { (response, messages) in
                self.conversation!.messages = messages
                if let m = messages.last {
                    self.conversation!.lastMessage = m
                    BMMessage.save(message: &self.conversation!.lastMessage!)
                }
                BMConversation.save(convo: &self.conversation!)
                self.tableView.fadeReload()
//                self.tableView.scrollToBottomNoAnim()
                self.tableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count - 1, section: 0), at: .bottom, animated: false)
                print("messages: ", self.conversation!.messages)
//                Timer.schedule(delay: 0.2) { (t) in
//                    self.tableView.show(duration: 0.2)
//                }
            }
        } else {
            self.tableView.hide(duration: 0)
            ConversationService.make().newConvo(receiver: self.otherUser!) { (response, c) in
                if let convo = c {
                    self.conversation = convo
                    self.tableView.fadeReload()
                    DispatchQueue.main.async {
                        self.scrollDown()
                    }
//                    self.scrollDown()
//                    self.tableView.scrollToBottomNoAnim()
//                    self.tableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count - 1, section: 0), at: .bottom, animated: false)
//                    Timer.schedule(delay: 0.1) { (t) in
//                        self.tableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count - 1, section: 0), at: .bottom, animated: false)
//                        self.tableView.show(duration: 0.2)
//                    }
                }
            }
        }
//        self.tableView.reloadData()
        self.extendedLayoutIncludesOpaqueBars = true
        tableView.contentInsetAdjustmentBehavior = .always
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadInNewMessage), name: NSNotification.Name("newMessageReceived"), object: nil)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNavBar()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = false
//        self.tableView.fadeReload()
//        self.removeRedDot(index: 2)
//        ProfileService.make().loadConversations(user: BMUser.me()) { (response, convos) in
//            ProfileService.make().user!.conversations = convos
//            self.tableView.fadeReload()
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showMessageNoti = true
    }
    
    func scrollDown() {
        if !self.conversation!.messages.isEmpty {
            self.tableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count - 1, section: 0), at: .bottom, animated: false)
        }
        Timer.schedule(delay: 0.1) { (t) in
            self.tableView.show(duration: 0.2)
        }
    }
    
    @objc func loadInNewMessage() {
        print("DID UPDATE MESSAGE ON CONVO PAGE")
        self.tableView.fadeReload()
        self.tableView.scrollToBottom()
    }
    
    func didReceiveMessage(message: BMMessage) {
        print("DID UPDATE MESSAGE ON CONVO PAGE: \(message.body!)")
        self.tableView.fadeReload()
        self.tableView.scrollToBottom()
    }
    
    @objc func reloadNotis() {
        self.tableView.refreshControl?.beginRefreshing()
        ConversationService.make().loadMessages(conversation: self.conversation!) { (response, messages) in
            self.conversation!.messages = messages
            if let m = messages.last {
                self.conversation!.lastMessage = m
                BMMessage.save(message: &self.conversation!.lastMessage!)
            }
            BMConversation.save(convo: &self.conversation!)
            self.tableView.fadeReload()
            self.tableView.scrollToBottom()
            Timer.schedule(delay: 0.2) { (t) in
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    // Do all navigation setup here
    func setNavBar() {
        if let c = self.conversation {
            if self.conversation!.sender!.id! == me.id! {
                self.setNavTitle(text: self.conversation!.receiver!.username!, font: BaseFont.get(.bold, 16), letterSpacing: 0.1, color: .label)
                self.setRightAvatar(user: self.conversation!.receiver!)
            } else {
                self.setNavTitle(text: self.conversation!.sender!.username!, font: BaseFont.get(.bold, 16), letterSpacing: 0.1, color: .label)
                self.setRightAvatar(user: self.conversation!.sender!)
            }
        } else {
            self.setNavTitle(text: self.otherUser!.username!, font: BaseFont.get(.bold, 16), letterSpacing: 0.1, color: .label)
            self.setRightAvatar(user: self.otherUser!)
        }
//        self.setRighAvatarItem(user: BMUser)
        self.setBackBtn(color: .label, animated: false)
//        extendedLayoutIncludesOpaqueBars = true
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func setRightAvatar(user: BMUser) {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imgView.layer.cornerRadius = 15
        imgView.layer.cornerCurve = .continuous
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        imgView.backgroundColor = .systemGray6
        imgView.setImage(string: user.avatar!)
        imgView.isUserInteractionEnabled = false
        let v = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        v.backgroundColor = .clear
        v.addSubview(imgView)
        v.addTarget(self, action: #selector(self.goToProf), for: .touchUpInside)
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goToProf))
//        v.addGestureRecognizer(tap)
//        v.isUserInteractionEnabled = true
        let btn = UIBarButtonItem(customView: v)
//        btn.action = #selector(self.goToProf)
//        btn.target = self
//        btn.style = .done
        
        self.navigationItem.setRightBarButton(btn, animated: false)
    }
    
    @objc func goToProf() {
        addHaptic(style: .soft)
        let vc = UserProfileViewController.makeVC(user: self.otherUser!)
        self.navigationController?.navigationBar.isTranslucent = false
        vc.hidesBottomBarWhenPushed = true
        vc.view.superview?.layoutIfNeeded()
        vc.view.layoutIfNeeded()
        vc.fromSearch = true
//        self.navigationController?.navigationBar.isTranslucent = true
        self.push(vc: vc)
//        self.push(vc: vc)
//        self.navigationController?.pushViewController(vc, animated: <#T##Bool#>)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = self.conversation {
            return c.messages.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let c = self.conversation {
            let message = self.conversation!.messages[indexPath.row]
            if message.senderId! == me.id! {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderMessageCell", for: indexPath) as! SenderMessageCell
                cell.conversation = self.conversation!
                cell.setMessage(message: message)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverMessageCell", for: indexPath) as! ReceiverMessageCell
                cell.conversation = self.conversation!
                cell.setMessage(message: message)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        addHaptic(style: .light)
        let newMessage = BMMessage(body: self.textView.text, convoId: self.conversation?.id ?? 0)
        self.conversation?.messages.append(newMessage)
        self.conversation?.lastMessage = newMessage
        BMConversation.save(convo: &self.conversation)
        if let i = self.tableView.indexPathsForVisibleRows {
//            self.tableView.insertRows(at: [IndexPath(row: self.tableView.indexPathsForVisibleRows!.last!.row + 1, section: self.tableView.indexPathsForVisibleRows!.last!.section)], with: .bottom)
////            self.tableView.scrollToBottomNoAnim()
//            self.tableView.reloadRows(at: [self.tableView.indexPathsForVisibleRows!.last!, self.tableView.indexPathsForVisibleRows![self.tableView.indexPathsForVisibleRows!.count - 1]], with: .bottom)
//            self.tableView.
//            self.tableView.reloadData()
//            Timer.schedule(delay: 0.1) { (t) in
//                self.tableView.scrollToBottomNoAnim()
//            }
//            self.tableView.scrollToBottomNoAnim()
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.conversation!.messages.count-1, section: 0)], with: .fade)
            if self.conversation!.messages.count > 1 {
                self.tableView.reloadRows(at: [IndexPath(row: self.conversation!.messages.count-2, section: 0)], with: .none)
            }
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: IndexPath(row: self.conversation!.messages.count-1, section: 0), at: .bottom, animated: true)
        } else {
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        }
//        self.tableView.insertRows(at: [self.tableView.indexPathsForVisibleRows!.last!], with: .fade)
//        self.tableView.scrollToBottom()
//        self.textView.text = ""
        self.postBtnWidthConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
//            self.tableView.scrollToBottom()
        }
//        self.view.endEditing(true)
        ConversationService.make().newMessage(message: self.textView.text!, conversation: self.conversation!) { (response) in
            print("Sent new message!: \(self.textView.text!)")
        }
        self.textView.text = ""
        
    }
}

extension ConversationViewController: UITextViewDelegate {
    
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
//        if self.commentForReply != nil {
//            self.textView.text = ""
//            self.commentForReply = nil
//        }
//        self.tableView.contentSize.height = self.tableView.contentSize.height - 300
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            self.textContainerBottomConstraint.constant = keyboardSize.height - 45
            if let c = self.conversation {
                self.textContainerBottomConstraint.constant = keyboardSize.height - 45
                if self.conversation!.messages.count >= 8 {
                    self.tableViewTop.constant = -keyboardSize.height - 45 - self.statusBarHeight() - (self.navigationController?.navigationBar.frame.size.height)!
                }
                if let c = self.conversation {
                    if c.messages.count > 3 {
                        self.tableView.scrollToBottomNoAnim()
                    }
                }
//                self.tableView.scrollToBottomNoAnim()
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { (complete) in
                    if complete {
    //                    self.tableView.scrollToBottom()
                    }
                }
            } else {
                self.textContainerBottomConstraint.constant = keyboardSize.height - 45
                self.tableViewTop.constant = -keyboardSize.height - 45 - self.statusBarHeight() - (self.navigationController?.navigationBar.frame.size.height)!
//                self.tableView.scrollToBottomNoAnim()
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                } completion: { (complete) in
                    if complete {
    //                    self.tableView.scrollToBottom()
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.textContainerBottomConstraint.constant != -34 {
            self.textContainerBottomConstraint.constant = -34
            self.tableViewTop.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.textView.placeholder = self.placeholder
            } completion: { (complete) in
                if complete {
//                    self.tableView.scrollToBottom()
                    if let c = self.conversation {
                        if c.messages.count > 3 {
                            self.tableView.scrollToBottomNoAnim()
                        }
                    }
                }
            }
        }
    }

}

