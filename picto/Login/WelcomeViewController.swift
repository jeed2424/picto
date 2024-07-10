//
//  WelcomeViewController.swift
//  InstagramFirestoreTutorial
//
//  Created by Richard on 3/12/21.
//  Copyright © 2021 Stephan Dowless. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn
//import FirebaseAnalytics

class WelcomeViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var introPic: UIImageView!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var loadingInd: UIActivityIndicatorView!
    @IBOutlet weak var signInButtonStack: UIStackView!
    @IBOutlet weak var appleLogo: UIImageView!
    //    @IBOutlet weak var registerBtn: UIButton!
    
    let auth = AuthenticationService.make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        introPic.hide(duration: 0)
        introPic.round()
        loadingInd.startAnimating()
//        Analytics.logEvent(AnalyticsEventLogin, parameters: {
//            AnalyticsParameterItemID: me.id
//        })
    //    signInButtonStack.hide(duration: 0)
  //      setUpSignInAppleButton()
        Timer.schedule(delay: 0.1) { (t) in
            self.introPic.show(duration: 0.2)
        }
        introPic.show(duration: 0.2)
//        auth.testLogin { (response, u) in
//            if let user = u {
////                self.loadingInd.stopAnimating()
////                self.auth.authenticationSuccess(user: user)
//                self.presentMain(load: false)
//            } else {
//                self.loadingInd.stopAnimating()
//             //   self.signInButtonStack.show(duration: 0.3)
//                let feed = FeedService.make()
//                feed.getFeed(all: true) { (response, posts) in
//                    feed.posts = posts.shuffled()
//                }
//            }
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        auth.testLogin { (response, u) in
//            if let user = u {
//                self.auth.authenticationSuccess(user: user)
//                self.presentMain()
//            } else {
//                self.signInButtonStack.show(duration: 0.3)
//            }
//        }
    }
    
//    func setUpSignInAppleButton() {
//        self.signInButtonStack.arrangedSubviews[0].alpha = 0
//        self.signInButtonStack.arrangedSubviews[1].alpha = 0
////        self.signInButtonStack.removeArrangedSubview(self.signInButtonStack.arrangedSubviews.first!)
////        self.signInButtonStack.removeArrangedSubview(self.signInButtonStack.arrangedSubviews.first!)
//        let authorizationButton = ASAuthorizationAppleIDButton()
//        authorizationButton.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)
////        authorizationButton.layer.cornerRadius = 25
//        authorizationButton.layer.cornerRadius = 25
//        authorizationButton.layer.masksToBounds = true
//        //Add button on some view or stack
//        self.signInButtonStack.addArrangedSubview(authorizationButton)
//        self.setGoogleBtn()
 //   }
    
//    func setGoogleBtn() {
//        let googleBtn = GIDSignInButton()
//        googleBtn.style = .wide
//        googleBtn.colorScheme = .dark
//        googleBtn.layer.cornerRadius = 25
//        googleBtn.layer.masksToBounds = true
//        self.signInButtonStack.addArrangedSubview(googleBtn)
//    }
    
//    @objc func doGoogleSignIn() {
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance()?.delegate = self
//        GIDSignIn.sharedInstance().signIn()
//    }
//
//    @objc func handleAppleIdRequest() {
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.requestedOperation = .operationLogin
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.performRequests()
//    }
    
    @IBAction func loginUser() {
        self.push(vc: LoginViewController.makeVC())
//        self.handleAppleIdRequest()
    }
    
    @IBAction func registerUser() {
        self.push(vc: RegisterViewController.makeVC())
//        self.doGoogleSignIn()
    }
    
    func presentMain(load: Bool = false) {
        if load == true {
            let feed = FeedService.make()
            feed.getFeed(all: true) { (response, posts) in
                feed.posts = posts.shuffled()
                Timer.schedule(delay: 0.2) { (t) in
                    self.loadingInd.stopAnimating()
                }
//                self.loadingInd.stopAnimating()
                self.signInBtn.isUserInteractionEnabled = true
                self.signInBtn.setTitle("Sign in with Apple", for: [])
                let tabBarController = CustomTabBarController()
                let home = HomeTestViewController.makeVC()
                let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
    //            let search = SearchController(config: .all)
                let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
    //            base2.navigationBar.prefersLargeTitles = true
    //            base2.navigationItem.largeTitleDisplayMode = .always
                let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
                if let user  = BMUser.me() {
                    let profile = UserProfileViewController.makeVC(user: user, fromTab: true)
                    let base4 = self.createVC(vc: profile, icon: UIImage(named: "profileicon")!.withTintColor(.systemGray), selected: UIImage(named: "profileicon-selected")!)
                    tabBarController.viewControllers = [base1, base2, base3, base4]
                } else {
                    tabBarController.viewControllers = [base1, base2, base3]
                }
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
        } else {
            self.loadingInd.stopAnimating()
            self.signInBtn.isUserInteractionEnabled = true
            self.signInBtn.setTitle("Sign in with Apple", for: [])
            let tabBarController = CustomTabBarController()
            let home = HomeTestViewController.makeVC()
            let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
//            let search = SearchController(config: .all)
            let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
//            base2.navigationBar.prefersLargeTitles = true
//            base2.navigationItem.largeTitleDisplayMode = .always
            let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
            if let user  = BMUser.me() {
                let profile = UserProfileViewController.makeVC(user: user, fromTab: true)
                let base4 = self.createVC(vc: profile, icon: UIImage(named: "profileicon")!.withTintColor(.systemGray), selected: UIImage(named: "profileicon-selected")!)
                tabBarController.viewControllers = [base1, base2, base3, base4]
            } else {
                tabBarController.viewControllers = [base1, base2, base3]
            }
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
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        self.loadingInd.startAnimating()
        self.signInBtn.isUserInteractionEnabled = false
        self.signInBtn.setTitle("Signing in...", for: [])
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            print("user id: ", userIdentifier)
            if let e = email {
                addHaptic(style: .light)
//                self.auth.registerUser(email: e, password: "password", firstName: fullName!.givenName!, lastName: fullName!.familyName!, appleId: userIdentifier) { (response, u) in
//                    if let user = u {
////                        self.signInBtn.setTitle("Signing in...", for: [])
////                        self.auth.authenticationSuccess(user: user)
//                        self.presentMain(load: false)
//                    }
//                }
            } else {
                addHaptic(style: .light)
//                self.auth.loginUserApple(appleId: userIdentifier) { (response, u) in
//                    if let user = u {
////                        self.auth.authenticationSuccess(user: user)
//                        self.presentMain(load: false)
//                    }
                }
            }
            
        }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
        print("error: ", error)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        self.loadingInd.startAnimating()
//        if let e = user.profile?.email {
//            self.auth.registerUser(email: e, password: "password", firstName: user.profile?.givenName! ?? "", lastName: user.profile?.familyName! ?? "", appleId: nil) { (response, u) in
//                if let usr = u {
//                    self.auth.authenticationSuccess(user: usr)
//                    self.presentMain()
//                }
//            }
//        }
//        if let error = error {
//            // ...
//            return
//        }
        
//        guard let authentication = user.authentication else { return }
//        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
//        if let e = user.profile.email {
//            self.auth.registerUser(email: e, password: "password", firstName: user.profile.givenName!, lastName: user.profile.familyName!, appleId: nil) { (response, u) in
//                if let usr = u {
//                    self.auth.authenticationSuccess(user: usr)
//                    self.presentMain()
//                }
//            }
//        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
}
