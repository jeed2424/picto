//
//  UserFollowersViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Knox Dobbins on 3/19/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import UIKit

protocol UserSearchDelegate {
    func goToProfile(user: BMUser)
}
class UserFollowersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 70
            tableView.contentInset.top = 15
        }
    }
    
    var user: BMUser!
    var followers = [BMUser]()
    var origUsers = [BMUser]()
    var forFollowing = false
    var forSearch = false
    var delegate: UserSearchDelegate?
    var searchText = ""
    
    static func makeVC(user: BMUser, following: Bool = false, forSearch: Bool = false, del: UserSearchDelegate? = nil) -> UserFollowersViewController {
        let vc = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserFollowersViewController") as! UserFollowersViewController
        vc.user = user
        vc.forFollowing = following
        vc.forSearch = forSearch
        vc.delegate = del
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setNavTitle(text: "Followers", font: BaseFont.get(.bold, 17))
        self.setBackBtn(color: .label, animated: false)
        self.tableView.reloadData()
        self.tableView.contentInset.bottom = 150
        self.tableView.keyboardDismissMode = .onDrag
        if self.forSearch {
            ProfileService.make().getFollowing(user: self.user!, discover: true) { (response, users) in
                self.followers = users
                self.origUsers = users
                self.user!.following = self.followers.map({$0.id!})
                self.tableView.fadeReload(duration: 0.15)
            }
        } else {
            if self.forFollowing == true {
                self.setNavTitle(text: "Following", font: BaseFont.get(.bold, 17))
                ProfileService.make().getFollowing(user: self.user!) { (response, users) in
                    self.followers = users
                    self.user!.following = self.followers.map({$0.id!})
                    self.tableView.fadeReload(duration: 0.15)
                }
            } else {
                self.setNavTitle(text: "Followers", font: BaseFont.get(.bold, 17))
                ProfileService.make().getFollowers(user: self.user!) { (response, users) in
                    self.followers = users
                    self.user!.followers = self.followers.map({$0.id!})
                    self.tableView.fadeReload(duration: 0.15)
                }
            }
        }
//        if self.forFollowing == true {
//            self.setNavTitle(text: "Following", font: BaseFont.get(.bold, 17))
//            ProfileService.make().getFollowing(user: self.user!) { (response, users) in
//                self.followers = users
//                self.user!.following = self.followers.map({$0.id!})
//                self.tableView.fadeReload(duration: 0.15)
//            }
//        } else {
//            self.setNavTitle(text: "Followers", font: BaseFont.get(.bold, 17))
//            ProfileService.make().getFollowers(user: self.user!) { (response, users) in
//                self.followers = users
//                self.user!.followers = self.followers.map({$0.id!})
//                self.tableView.fadeReload(duration: 0.15)
//            }
//        }
    }
    
    func search(text: String, users: [BMUser]) {
        self.searchText = text
        if text == "" {
            self.followers = self.origUsers
            self.tableView.fadeReload(duration: 0.1)
        } else {
            self.followers = users
            self.tableView.fadeReload(duration: 0.1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.forFollowing == true {
            self.setNavTitle(text: "Following", font: BaseFont.get(.bold, 17))
        } else {
            self.setNavTitle(text: "Followers", font: BaseFont.get(.bold, 17))
        }
        self.setBackBtn(color: .label, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.forFollowing == true {
            self.setNavTitle(text: "Following", font: BaseFont.get(.bold, 17))
        } else {
            self.setNavTitle(text: "Followers", font: BaseFont.get(.bold, 17))
        }
        self.setBackBtn(color: .label, animated: false)
        if self.forSearch {
            if self.searchText.replacingOccurrences(of: " ", with: "") != "" {
                ProfileService.make().getFollowing(user: self.user!, discover: true) { (response, users) in
                    self.followers = users
                    self.origUsers = users
                    self.user!.following = self.followers.map({$0.id!})
                    self.tableView.fadeReload(duration: 0.15)
                }
            }
        }
    }
    
    
}

extension UserFollowersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserFollowerCell", for: indexPath) as! UserFollowerCell
        cell.setUser(user: self.followers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let d = self.delegate {
            d.goToProfile(user: self.followers[indexPath.row])
        } else {
            let vc = UserProfileViewController.makeVC(user: self.followers[indexPath.row])
            vc.fromSearch = self.forSearch
            vc.hidesBottomBarWhenPushed = true
            self.push(vc: vc)
        }
    }
}

class UserFollowerCell: UITableViewCell {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var user: BMUser!
    
    func setUser(user: BMUser) {
        self.user = user
        avatar.setImage(string: user.avatar!)
        avatar.round()
        nameLbl.text = user.username!
        checkUser(user: user)
    }
    
    func checkUser(user: BMUser) {
        if BMUser.me().id! == user.id! {
            self.followBtn.alpha = 0
        } else {
            self.followBtn.alpha = 1
            if BMUser.me().checkFollow(user: user) == true {
                self.followBtn.setTitle("Following", for: [])
            } else {
                self.followBtn.setTitle("Follow", for: [])
            }
        }
    }
    
    @IBAction func followAction(_ sender: Any) {
        addHaptic(style: .medium)
        if BMUser.me().id! == self.user!.id! {
            return
        } else {
            if BMUser.me().checkFollow(user: self.user!) == true {
                self.followBtn.setTitle("Follow", for: [])
                if let index = self.user!.followers.index(of: BMUser.me().id!) {
                    self.user!.followers.remove(at: index)
                }
            } else {
                self.followBtn.setTitle("Following", for: [])
                self.user!.followers.append(BMUser.me().id!)
            }
            BMUser.save(user: &self.user!)
//            ProfileService.make().followUser(user: self.user!) { (response, u) in
//                print("followed user")
//            }
        }
    }
    
}
