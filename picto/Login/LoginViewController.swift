//
//  LoginViewController.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/25/21.
//  Copyright © 2021 Warbly. All rights reserved.
//
import Foundation
import UIKit
import SkyFloatingLabelTextField

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTF: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTF: SkyFloatingLabelTextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    let auth = AuthenticationService.make()
    
    static func makeVC() -> LoginViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavTitle(text: "Log in", font: BaseFont.get(.bold, 18))
        self.setBackBtn(color: .label, animated: false)
        self.hideKeyboardWhenTappedAround()
        setTFs()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setTFs() {
        emailTF.delegate = self
        passwordTF.delegate = self
        checkTFs()
    }
    
    // This will notify us when something has changed on the textfield
    @IBAction func textFieldChanged(_ sender: SkyFloatingLabelTextField) {
        if let text = sender.text {
            if sender == self.emailTF {
                if(text.count < 3 || !text.contains("@")) {
                    sender.errorMessage = "Invalid email"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    sender.errorMessage = ""
                }
            }
        }
        checkTFs()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTFs()
    }
    
    func checkTFs() {
        if emailTF.text!.isEmpty && passwordTF.text!.isEmpty {
            self.loginBtn.isEnabled = true
            self.loginBtn.backgroundColor = .label
        } else {
            self.loginBtn.isEnabled = false
            self.loginBtn.backgroundColor = .systemGray5
        }
    }
    
    @IBAction func loginUser() {
//        self.presentLoadingAlertModal(animated: true, completion: nil)
//        auth.loginUser(email: emailTF.text!, password: passwordTF.text!) { (response, u) in
//            Timer.schedule(delay: 0.3) { (t) in
//                self.dismissLoadingAlertModal(animated: true) {
//                    if let usr = u {
//                        self.auth.authenticationSuccess(user: usr)
//                        self.presentMain()
//                    }
//                }
//            }
//        }
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
