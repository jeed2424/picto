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
import SupabaseManager

class RegisterProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var registerBtn: UIButton!


//    private lazy var usernameField: SkyFloatingLabelTextField = {
//        let field = SkyFloatingLabelTextField()
//        field.translatesAutoresizingMaskIntoConstraints = false
//
//        field.keyboardType = .emailAddress
//        field.autocapitalizationType = .none
//        field.textColor = .black
//
//        field.placeholder = "Username"
//        field.title = "Username"
//        field.errorColor = .systemRed
//
//        field.addTarget(self, action: #selector(verifyUsername(_:)), for: .editingChanged)
//
//        return field
//    }()

    let auth = AuthenticationService.make()
    
    var user: BMUser?

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
        setUsernameField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func updateUser() {
        guard let user = self.user else { return }

//       ProfileService.make().updateUser(user: self.user) { (response, u) in
//           print("\(u)")
//            if let usr = u {
//                self.auth.authenticationSuccess(user: usr)
//                self.presentMain()
//            }
//        }

        saveNewUser(user: user)

    }

    private func saveNewUser(user: BMUser) {
        guard let userId = user.identifier, let username = usernameTF.text?.noSpaces(), let firstName = user.firstName, let lastName = user.lastName, let email = user.email else { return }

        let manager = SupabaseAuthenticationManager.sharedInstance

        let user = DbUser(id: userId, username: username, firstName: firstName, lastName: lastName, email: email)

        manager.createNewUser(user: user, completion: { id in
            if id != nil {
                //                self.auth.authenticationSuccess(user: usr)
                if let user = manager.authenticatedUser {
                    let bmUser = BMUser(id: user.id, username: user.username, firstName: user.firstName, lastName: user.lastName, email: user.email)
                    let auth = AuthenticationService.make()
                    auth.authenticationSuccess(user: bmUser)
                    if let user  = self.user {
                        ProfileService.sharedInstance.saveUser(user: user)
                    }
//                    DispatchQueue.main.async {
//                        self.presentMain()
//                    }
                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: bmUser)
//                    NotificationCenter.default.post(name: NotificationNames.didRegister, object: bmUser)
                }
            }
        })
    }

//    @IBAction func textFieldChanged(_ sender: SkyFloatingLabelTextField) {
//        self.user?.username = sender.text
//        checkTFs()
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkTFs()
    }

    private func setUsernameField() {
        usernameTF.keyboardType = .emailAddress
        usernameTF.autocapitalizationType = .none
        usernameTF.textColor = .black

        usernameTF.errorColor = .systemRed

        usernameTF.addTarget(self, action: #selector(verifyUsername(_:)), for: .editingChanged)
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
        
//        ImageExporter.shared.export(image: session.image!, compressionQuality: 0.5) { (error, img) in
//            self.avatar.image = img!
//            ProfileService.make().uploadToFirebaseImage(user: BMUser.me(), image: img!) { (imgUrl) in
//                ProfileService.make().user!.avatar = imgUrl
//                ProfileService.make().updateAvatar(user: BMUser.me()) { (response, u) in
//                    if let usr = u {
//        ProfileService.sharedInstance.saveUser(user: self.user)
//                    }
                    editController.dismissLoadingAlertModal(animated: true) {
                        editController.dismiss(animated: true, completion: nil)
                    }
//                }
//            } failure: { (error) in
//                print("error: ", error)
//                editController.dismissLoadingAlertModal(animated: true) {
//                    editController.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    func presentMain() {
        let feed = FeedService.make()
//        feed.getFeed(all: true) { (response, posts) in
//            feed.posts = posts
            let tabBarController = CustomTabBarController()
            let home = HomeTestViewController.makeVC()
            let base1 = self.createVC(vc: home, icon: UIImage(named: "homeicon1")!.withTintColor(.systemGray), selected: UIImage(named: "homeicon1-selected")!)
//            let search = SearchController(config: .all)
            let base2 = self.createVC(vc: DiscoverViewController.makeVC(), icon: UIImage(named: "searchicon")!.withTintColor(.systemGray), selected: UIImage(named: "searchicon-selected")!)
            let base3 = self.createVC(vc: UserNotificationsViewController.makeVC(), icon: UIImage(named: "notificationbell")!.withTintColor(.systemGray), selected: UIImage(named: "notificationbell-selected")!)
        if let user = BMUser.me() {
            if let profile = UserProfileViewController.makeVC(user: user, fromTab: true) {
                let base4 = self.createVC(vc: profile, icon: UIImage(systemName: "pencil.circle")!.withTintColor(.systemGray), selected: UIImage(systemName: "pencil.circle.fill")!)
                tabBarController.viewControllers = [base1, base2, base3, base4]
            } else {
                tabBarController.viewControllers = [base1, base2, base3]
            }
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
//        }
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

extension RegisterProfileViewController {
    @objc func verifyUsername(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                if text.count < 3 {
                    floatingLabelTextField.errorMessage = "Username must have at least 3 characters"
                } else if text.contains(" ") {
                    floatingLabelTextField.errorMessage = "Username must not contain spaces"
                } else {
                    self.user?.username = textfield.text
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }
}

