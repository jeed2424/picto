//
//  EditProfileViewController.swift
//  Warbly
//
//  Created by Knox Dobbins on 3/29/21.
//  Copyright © 2021 Warbly. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField
import SafariServices
import PixelSDK
import Delighted

class EditProfileViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameTF: SkyFloatingLabelTextField!
    @IBOutlet weak var websiteTF: SkyFloatingLabelTextField!
    @IBOutlet weak var instagramTF: SkyFloatingLabelTextField!
    @IBOutlet weak var bioTextView: UITextView!

    private lazy var hStack: UIStackView = {
        let stack = UIStackView()

        stack.axis = .horizontal
        stack.spacing = 10

        return stack
    }()

    private lazy var lblShowName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "Show full name?"

        return label
    }()

    private lazy var showNameSegment: UISegmentedControl = {
        let segment = UISegmentedControl()

        segment.selectedSegmentIndex = user.showName ? 1 : 0

        return segment
    }()
    
    var user: BMUser!
    
    static func makeVC(user: BMUser) -> EditProfileViewController {
        let vc = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        vc.user = user
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTF.delegate = self
        websiteTF.delegate = self
        instagramTF.delegate = self
        bioTextView.delegate = self
        bioTextView.isScrollEnabled = true
        avatar.round()
        self.setUser()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.editAvatar))
        self.avatar.addGestureRecognizer(tap)
        self.avatar.isUserInteractionEnabled = true
        self.setNav()
        self.hideKeyboardWhenTappedAround()
//        showFeedback(vc: self, title: "This is a Test Feedback")
        self.editUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNav()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNav()
    }
    
    func setNav() {
        self.setBackBtn(color: .label, animated: false)
        self.setNavTitle(text: "Edit Profile", font: BaseFont.get(.bold, 17))
        self.setRightNavBtnText(text: "Save", action: #selector(self.saveProfile))
    }

    private func editUI() {
//        view.insertSubview(hStack, belowSubview: instagramTF)
//
//        NSLayoutConstraint.activate([
//            hStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            hStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
//            hStack.topAnchor.constraint(equalTo: instagramTF.bottomAnchor, constant: 10),
//            hStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
//        ])
//
//        hStack.addArrangedSubviews([
//            lblShowName,
//            showNameSegment
//        ])

    }
    
    @objc func saveProfile() {
        self.view.endEditing(true)
        self.presentLoadingAlertModal(animated: true, completion: nil)
        Timer.schedule(delay: 0.15) { (t) in
            ProfileService.make().updateProfile(user: self.user!) { (response, u) in
                if let usr = u {
                    self.user! = usr
                    ProfileService.make().user = usr
                    BMUser.save(user: &ProfileService.make().user!)
                    addHaptic(style: .success)
                    Timer.schedule(delay: 0.15) { (t) in
                        self.dismissLoadingAlertModal(animated: true) {
                            self.popVC()
                        }
                    }
                }
            }
        }
    }
    
    func setUser() {
        if self.user!.avatar != nil {
            self.avatar.setImage(string: self.user!.avatar!)
            print("Avatar: \(self.user!.avatar!)")
        }
        self.usernameTF.text = self.user!.username!
        self.websiteTF.text = self.user!.website ?? ""
        self.bioTextView.text = self.user!.bio ?? ""
        self.instagramTF.text = self.user!.instagram ?? ""
    }
    
    @IBAction func usernameChanged(_ sender: SkyFloatingLabelTextField) {
        if sender.text! != self.user!.username! && !sender.text!.replacingOccurrences(of: " ", with: "").isEmpty {
            ProfileService.make().checkUsername(username: sender.text!.replacingOccurrences(of: " ", with: "")) { (response) in
                if response == .Success {
                    self.user!.username = sender.text!.replacingOccurrences(of: " ", with: "")
                    sender.errorMessage = ""
                } else {
                    sender.errorMessage = "Username already taken"
                }
            }
        } else if sender.text!.replacingOccurrences(of: " ", with: "").count < 1 {
            sender.errorMessage = "Can't be empty"
        } else {
            self.user!.username = sender.text!.replacingOccurrences(of: " ", with: "")
            sender.errorMessage = ""
        }
    }
    
    @IBAction func websiteChanged(_ sender: SkyFloatingLabelTextField) {
        self.user!.website = sender.text!.replacingOccurrences(of: " ", with: "")
        websiteTF.isHidden = false
        websiteTF.isEnabled = true
    }
    
    @IBAction func instagramChanged(_ sender: SkyFloatingLabelTextField) {
        self.user!.instagram = sender.text!.replacingOccurrences(of: " ", with: "")
        instagramTF.isHidden = false
        instagramTF.isEnabled = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.websiteTF {
            self.tableView.setContentOffset(CGPoint(x: 0, y: 350), animated: true)
        }
        
        if textField == self.instagramTF {
            self.tableView.setContentOffset(CGPoint(x: 0, y: 450), animated: true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.user!.bio = textView.text!
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    override public func editController(_ editController: EditController, didFinishEditing session: Session) {
//        editController.presentLoadingAlertModal(animated: true, completion: nil)
//        
//        ImageExporter.shared.export(image: session.image!, compressionQuality: 0.5) { (error, img) in
//            self.avatar.image = img!
//            ProfileService.make().uploadToFirebaseImage(user: BMUser.me(), image: img!) { (imgUrl) in
//                ProfileService.make().user!.avatar = imgUrl
//                ProfileService.make().updateAvatar(user: BMUser.me()) { (response, u) in
//                    if let usr = u {
//                        ProfileService.make().user = usr
//                        self.tableView.reloadData()
//                    }
//                    editController.dismissLoadingAlertModal(animated: true) {
//                        editController.dismiss(animated: true, completion: nil)
//                    }
//                }
//            } failure: { (error) in
//                print("error: ", error)
//                editController.dismissLoadingAlertModal(animated: true) {
//                    editController.dismiss(animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    @IBAction func viewWebsite(_ sender: Any) {
        var w = self.user!.website ?? ""
        if w.contains("http") == false {
            w = "https://\(w)"
        }
        if w != "https://" {
            if let url = URL(string: w.lowercased()) {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func viewInsta(_ sender: Any) {
        if let url = URL(string: "https://www.instagram.com/\(self.user!.instagram!.replacingOccurrences(of: " ", with: ""))/") {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
}

var me: BMUser {
    return BMUser.me()
}

func showFeedback(vc: UIViewController, title: String) {
//    Options(
//    Options(
    let example = Example(label: title,
            delightedID: "mobile-sdk-FyS0rWudJOXsuJjE",
            options: Options(
                poweredByLinkText: "From your friends at Gala",
                nextText: "Next 👉",
                prevText: "👈 Previous",
                selectOneText: "Select one",
                selectManyText: "Select many",
                submitText: "Submit 👌",
                doneText: "Done ✅",
                notLikelyText: "Not likely",
                veryLikelyText: "Very likely",
                theme: Theme(
                    display: .card,
                    containerCornerRadius: 20.0,
                    primaryColor: .black,
                    buttonStyle: .solid,
                    buttonShape: .roundRect,
                    backgroundColor: .white,
                    primaryTextColor: .black,
                    secondaryTextColor: .systemGray,
                    textarea: Theme.TextArea(
                        backgroundColor: .white,
                        textColor: .black,
                        borderColor: .systemGray5),
                    primaryButton: Theme.PrimaryButton(
                        backgroundColor: .black,
                        textColor: .white,
                        borderColor: .black),
                    secondaryButton: Theme.SecondaryButton(
                        backgroundColor: .black,
                        textColor: .white,
                        borderColor: .black),
                    button: Theme.Button(
                        activeBackgroundColor: .black,
                        activeTextColor: .white,
                        activeBorderColor: .black,
                        inactiveBackgroundColor: .systemGray5,
                        inactiveTextColor: .white,
                        inactiveBorderColor: .systemGray5),
                    stars: Theme.Stars(
                        activeBackgroundColor: .black,
                        inactiveBackgroundColor: .systemGray5),
                    icon: Theme.Icon(
                        activeBackgroundColor: .black,
                        inactiveBackgroundColor: .systemGray5),
                    scale: Theme.Scale(
                        activeBackgroundColor: .white,
                        activeTextColor: .black,
                        activeBorderColor: .systemGray5,
                        inactiveBackgroundColor: .systemGray5,
                        inactiveTextColor: .white,
                        inactiveBorderColor: .systemGray5),
                    slider: Theme.Slider(
                        knobBackgroundColor: .black,
                        knobTextColor: .white,
                        knobBorderColor: .black,
                        trackActiveColor: .black,
                        trackInactiveColor: .systemGray3,
                        hoverBackgroundColor: .black,
                        hoverTextColor: .black,
                        hoverBorderColor: .black),
                    closeButton: Theme.CloseButton(
                        normalBackgroundColor: .systemGray5,
                        normalTextColor: .white,
                        normalBorderColor: .systemGray5,
                        highlightedBackgroundColor: .systemGray3,
                        highlightedTextColor: .white,
                        highlightedBorderColor: .systemGray3),
                    ios: Theme.IOS(keyboardAppearance: .light,
                                   statusBarMode: .lightContent,
                                   statusBarHidden: false)
                ),
                thankYouAutoCloseDelay: 3
            )
    )
    
    let delightedID = example.delightedID
    let person = Person(name: me.fullName, email: me.email!, phoneNumber: nil)
    let properties = example.properties
    let options = example.options
    
    let eligibilityOverrides = EligibilityOverrides(
        testMode: true,
        createdAt: Date(),
        initialDelay: nil,
        recurringPeriod: nil
    )
    Delighted.survey(delightedID: delightedID, person: person, properties: properties, options: options, eligibilityOverrides: eligibilityOverrides, inViewController: nil, callback: { [unowned vc] (status) in
        
        switch status {
        case let .failedClientEligibility(error):
            print("failedClientEligibility: \(error)")
        case let .error(error):
            print("error: \(error)")
        case let .surveyClosed(status):
            print("surveyClosed - \(status)")
        }
//        vc.dismiss(animated: true, completion: nil)
//        self.performSegue(withIdentifier: "unwindToExamples", sender: self)
    })
}

struct Example {
    let label: String
    let delightedID: String
    var person: Person?
    var properties: Properties?
    var options: Options?
}
