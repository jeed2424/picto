//
//  RegisterProfileViewController.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/25/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import PixelSDK
import Firebase

class RegisterProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    let auth = AuthenticationService.make()
    
    var user: BMUser!
    
    static func makeVC(user: BMUser) -> RegisterProfileViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "RegisterProfileViewController") as! RegisterProfileViewController
        vc.user = user
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavTitle(text: "Update Profile", font: BaseFont.get(.bold, 18))
        self.hideKeyboardWhenTappedAround()
        usernameTF.delegate = self
        avatar.round()
      //  avatar.setImage(string: self.user!.avatar!)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.editAvatar))
        self.avatar.addGestureRecognizer(tap)
        self.avatar.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func updateUser() {
       ProfileService.make().updateUser(user: self.user!) { (response, u) in
           print("\(u)")
            if let usr = u {
                self.auth.authenticationSuccess(user: usr)
                self.presentMain()
            }
        }

    }
    
    @IBAction func textFieldChanged(_ sender: SkyFloatingLabelTextField) {
        self.user!.username = sender.text!
        checkTFs()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTFs()
    }
    
    func checkTFs() {
        if !usernameTF.text!.isEmpty {
            self.registerBtn.isEnabled = true
            self.registerBtn.backgroundColor = .label
        } else {
            self.registerBtn.isEnabled = false
            self.registerBtn.backgroundColor = .systemGray5
        }
    }
    
    override public func editController(_ editController: EditController, didFinishEditing session: Session) {
        editController.presentLoadingAlertModal(animated: true, completion: nil)
        
        ImageExporter.shared.export(image: session.image!, compressionQuality: 0.5) { (error, img) in
            self.avatar.image = img!
            ProfileService.make().uploadToFirebaseImage(user: BMUser.me(), image: img!) { (imgUrl) in
                ProfileService.make().user!.avatar = imgUrl
                ProfileService.make().updateAvatar(user: BMUser.me()) { (response, u) in
                    if let usr = u {
                        ProfileService.make().user = usr
                    }
                    editController.dismissLoadingAlertModal(animated: true) {
                        editController.dismiss(animated: true, completion: nil)
                    }
                }
            } failure: { (error) in
                print("error: ", error)
                editController.dismissLoadingAlertModal(animated: true) {
                    editController.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentMain() {
        let feed = FeedService.make()
        feed.getFeed(all: true) { (response, posts) in
            feed.posts = posts
            let tabBarController = CustomTabBarController()
            let home = HomeTestViewController.makeVC()
            let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
//            let search = SearchController(config: .all)
            let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
            let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
            let profile = UserProfileViewController.makeVC(user: BMUser.me(), fromTab: true)
            let base4 = self.createVC(vc: profile, icon: UIImage(named: "profileicon")!.withTintColor(.systemGray), selected: UIImage(named: "profileicon-selected")!)
            tabBarController.viewControllers = [base1, base2, base3, base4]
            tabBarController.tabBar.tintColor = .label
            tabBarController.tabBar.barTintColor = .systemBackground
            tabBarController.tabBar.isTranslucent = false
            tabBarController.tabBar.shadowImage = UIImage()
            tabBarController.tabBar.backgroundImage = UIImage()
            tabBarController.modalPresentationStyle = .fullScreen
            tabBarController.view.backgroundColor = .systemBackground
            tabBarController.modalTransitionStyle = .crossDissolve
            ProfileService.make().tabController = tabBarController
            self.present(tabBarController, animated: true, completion: nil)
        }
    }
    
    func createVC(vc: UIViewController, icon: UIImage, selected: UIImage) -> BaseNC {
        vc.tabBarItem = UITabBarItem(title: "", image: icon, tag: 0)
        vc.tabBarItem.selectedImage = selected
        let nc = BaseNC(rootViewController: vc)
        return nc
    }
    
    func createVCNav(vc: UIViewController, icon: UIImage, selected: UIImage) -> UINavigationController {
        vc.tabBarItem = UITabBarItem(title: "", image: icon, tag: 0)
        vc.tabBarItem.selectedImage = selected
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }

}

