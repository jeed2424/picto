import Foundation
import UIKit
import SkyFloatingLabelTextField
import SafariServices
import Combine
import SwiftUI
import SupabaseManager

class NewEditProfileViewController: KeyboardManagingViewController, UITextFieldDelegate, UITextViewDelegate, SJFluidSegmentedControlDataSource, SJFluidSegmentedControlDelegate {

    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false

        view.alwaysBounceVertical = true
        view.bounces = true

        return view
    }()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.alignment = .center

        stack.spacing = 35

        return stack
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .horizontal
        stack.spacing = 10

        return stack
    }()

    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .vertical)

        return view
    }()

    private lazy var usernameTF: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        return field
    }()

    private lazy var websiteTF: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Website"

        return field
    }()

    private lazy var instagramTF: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Instagram Username"

        return field
    }()

    private lazy var bioTextView: UITextView = {
        let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "Bio"

        view.borderWidth = 1
        view.borderColor = .systemGray
        view.layer.cornerRadius = 4
        view.font = .systemFont(ofSize: 14, weight: UIFont.Weight.regular)

        return view
    }()

    private lazy var lblShowName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .label
        label.text = "Show full name?"

        return label
    }()

    lazy var showNameSegment: SJFluidSegmentedControl = {
        [unowned self] in
        // Setup the frame per your needs
        let segmentedControl = SJFluidSegmentedControl(frame: CGRect(x: 0, y: 0, width: 75, height: lblShowName.frame.height))
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.dataSource = self
        segmentedControl.delegate = self
        segmentedControl.currentSegment = user?.showName ?? false ? 1 : 0

        segmentedControl.shadowsEnabled = false
        segmentedControl.applyCornerRadiusToSelectorView = true

        segmentedControl.layer.cornerRadius = 7
        segmentedControl.textFont = .systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        segmentedControl.transitionStyle = .slide
        segmentedControl.selectorViewColor = .defined.cyan100()

        return segmentedControl
    }()

    // MARK: - Variables
    var user: BMUser?

    private var avatarData: Data?
    private var avatarEmptyAtLaunch: Bool?
    private var avatarDidChange: Bool = false

    static func makeVC(user: BMUser) -> NewEditProfileViewController {
        let vc = NewEditProfileViewController()
        vc.user = BMUser.me()
        print("Launch EditProfile: \(user.avatar)")
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(imagePickerShow))
        self.avatar.addGestureRecognizer(tap)
        self.avatar.isUserInteractionEnabled = true
        self.setNav()
        self.hideKeyboardWhenTappedAround()
        //        showFeedback(vc: self, title: "This is a Test Feedback")
        self.setupStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNav()
        if self.user?.avatar == nil || self.user?.avatar?.isEmpty ?? true {
            self.avatarEmptyAtLaunch = true
        } else {
            self.avatarEmptyAtLaunch = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNav()
        self.setUser()
         //setImage(string: self.user?.avatar ?? "", placeholderImg: UIImage(named: "personicon"))
    }

    func setNav() {
        self.setBackBtn(color: .label, animated: false)
        self.setNavTitle(text: "Edit Profile", font: BaseFont.get(.bold, 17))
        self.setRightNavBtnText(text: "Save", action: #selector(self.saveProfile))
    }

    private func setupStyle() {
        view.backgroundColor = .backgroundColor
        view.addSubview(scrollView)
        scrollView.addSubview(vStack)
        //        view.insertSubview(hStack, belowSubview: instagramTF)

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35)
        ])

        NSLayoutConstraint.activate([
            // Set scroll view's frame
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Scroll view's content is pinned to the bounds of the contentView.
            scrollView.contentLayoutGuide.topAnchor.constraint(equalTo: vStack.topAnchor),
            scrollView.contentLayoutGuide.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            scrollView.contentLayoutGuide.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: vStack.bottomAnchor),

            // Extend content to frame layout guide's bottom anchor (and beyond)
            scrollView.contentLayoutGuide.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.bottomAnchor),

            // Disable horizontal scrolling.
            scrollView.frameLayoutGuide.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor)
        ])

        // scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60 + LayoutConstant.bottomSafeArea, right: 0)

        vStack.addArrangedSubviews([
            avatar,
            usernameTF,
            bioTextView,
            websiteTF,
            instagramTF,
            hStack
        ])

        hStack.addArrangedSubviews([
            lblShowName,
            showNameSegment
        ])

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 120),
            avatar.heightAnchor.constraint(equalToConstant: 120),
            usernameTF.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            usernameTF.heightAnchor.constraint(equalToConstant: 40),
            bioTextView.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            bioTextView.heightAnchor.constraint(equalToConstant: 220),
            websiteTF.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            websiteTF.heightAnchor.constraint(equalToConstant: 40),
            instagramTF.widthAnchor.constraint(equalTo: vStack.widthAnchor),
            instagramTF.heightAnchor.constraint(equalToConstant: 40),
            showNameSegment.widthAnchor.constraint(equalToConstant: 75),
            showNameSegment.heightAnchor.constraint(equalTo: lblShowName.heightAnchor)
        ])

    }

    @objc func saveProfile() {
        guard let user = self.user else { return }
        self.view.endEditing(true)
        self.presentLoadingAlertModal(animated: true, completion: nil)
        Timer.schedule(delay: 0.15) { (t) in
//            ProfileService.sharedInstance.updateProfile(user: self.user!) { (response, u) in
//                if let usr = u {
//                    self.user! = usr
//                    ProfileService.make().user = usr
//                    BMUser.save(user: &ProfileService.make().user!)
//                    addHaptic(style: .success)
//                    Timer.schedule(delay: 0.15) { (t) in
//                        self.dismissLoadingAlertModal(animated: true) {
//                            self.popVC()
//                        }
//                    }
//                }
//            }
            if self.avatarDidChange {
                self.saveAvatar(completion: { _ in
                    print("Hello on save profile \(self.user?.avatar)")
                    self.saveUser(user: user)
                })
            } else {
                self.saveUser(user: user)
            }
        }
    }

    private func saveAvatar(completion: @escaping (Bool) -> ()) {
        guard let data = self.avatarData else { return }
        let manager = SupabaseStorageManager.sharedInstance
        Task {
            do {
                if avatarEmptyAtLaunch ?? false || (self.user?.avatar == nil || self.user?.avatar?.isEmpty ?? false) {
                    try await manager.uploadAvatar(user: user?.identifier ?? UUID(), image: data, completion: { url in
                        self.user?.avatar = url
                        completion(true)
                    })
                } else {
                    try await manager.updateAvatar(user: user?.identifier ?? UUID(), image: data, completion: { url in
                        self.user?.avatar = url
                        completion(true)
                    })
                }
            } catch {
                completion(false)
            }
        }
    }

    private func saveUser(user: BMUser) {
        let authManager = SupabaseAuthenticationManager.sharedInstance
        let profileService = ProfileService.sharedInstance
        let authService = AuthenticationService.sharedInstance

        let postIds: [Int8] = user.posts.compactMap { post in post.postID }
        
        print("Hello saveUser: \(user.avatar)")
        let dbUser = DbUser(id: user.identifier ?? UUID(), username: user.username ?? "", firstName: user.firstName ?? "", lastName: user.lastName ?? "", email: user.email ?? "", bio: user.bio ?? "", website: user.website ?? "", showFullName: user.showName, avatar: user.avatar ?? "", posts: postIds)
        print("Hello DBUser: \(dbUser.avatar)")

        authManager.updateUser(user: dbUser, completion: {[weak self] updatedUser in
            guard let self = self else { return }
            if let updatedUser = updatedUser {
//                self.auth.authenticationSuccess(user: usr)
//                if let user = manager.authenticatedUser {
                let userUpdate = BMUser(id: updatedUser.id, username: updatedUser.username, firstName: updatedUser.firstName, lastName: updatedUser.lastName, email: updatedUser.email, bio: updatedUser.bio, website: updatedUser.website, showFullName: updatedUser.showFullName, avatar: updatedUser.avatar, posts: user.posts)
                    profileService.updateUser(user: userUpdate)
                    authService.saveUpdatedUser(user: userUpdate)
                    self.dismissLoadingAlertModal(animated: true) {
                        self.user = userUpdate
                        self.refreshUser(completion: { _ in
                            self.popVC()
                        })
                    }
//                }
            }
        })

    }

    func setUser() {

//        if self.user?.avatar != nil {
        avatar.setComplexImage(url: self.user?.avatar ?? "", placeholder: UIImage(named: "personicon") ?? UIImage(), forceRefresh: false, completion: { _ in
            
        })
//            self.avatar.setImage(string: self.user?.avatar ?? "")
            print("Avatar: \(self.user?.avatar)")
//        }
        self.usernameTF.text = self.user?.username ?? ""
        self.websiteTF.text = self.user?.website ?? ""
        self.bioTextView.text = self.user?.bio ?? ""
        self.instagramTF.text = self.user?.instagram ?? ""
    }
    
    func refreshUser(completion: @escaping (Bool) -> ()) {

//        if self.user?.avatar != nil {
//            self.avatar.setImage(string: self.user?.avatar ?? "")
            print("Avatar: \(self.user?.avatar)")
//        }
        self.usernameTF.text = self.user?.username ?? ""
        self.websiteTF.text = self.user?.website ?? ""
        self.bioTextView.text = self.user?.bio ?? ""
        self.instagramTF.text = self.user?.instagram ?? ""
        
        avatar.setComplexImage(url: self.user?.avatar ?? "", placeholder: UIImage(named: "personicon") ?? UIImage(), forceRefresh: true, completion: { complete in
            completion(complete)
        })
    }
}

// MARK: - Functions
extension NewEditProfileViewController {

    func textViewDidChange(_ textView: UITextView) {
        if textView == usernameTF {
            self.user?.username = textView.text ?? ""
        } else if textView == bioTextView {
            self.user?.bio = textView.text ?? ""
        } else if textView == websiteTF {
            self.user?.website = textView.text ?? ""
        } else if textView == instagramTF {
            self.user?.instagram = textView.text ?? ""
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

// MARK: - SJFluidSegmentedControl
extension NewEditProfileViewController {

    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 2
    }

    @objc func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                                titleForSegmentAtIndex index: Int) -> String? {
        switch index {
        case 0:
            return "No"
        case 1:
            return "Yes"
        default:
            return ""
        }
    }

    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          gradientColorsForBounce bounce: SJFluidSegmentedControlBounce) -> [UIColor] {
        switch bounce {
        case .left:
            return [UIColor(red: 51 / 255.0, green: 149 / 255.0, blue: 182 / 255.0, alpha: 1.0)]
        case .right:
            return [UIColor(red: 9 / 255.0, green: 82 / 255.0, blue: 107 / 255.0, alpha: 1.0)]
        }
    }

    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          didChangeFromSegmentAtIndex fromIndex: Int,
                          toSegmentAtIndex toIndex:Int) {
        switch toIndex {
        case 0:
            self.user?.showName = false
        case 1:
            self.user?.showName = true
        default:
            break
        }
    }

}

extension NewEditProfileViewController {
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
                                      [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as? UIImage
        let data = image?.jpegData(compressionQuality: 0.5)

        self.avatar.image = image
        self.avatarDidChange = true
        self.avatarData = data

        print("Hello Image Selected")
//        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func imagePickerShow() {
        self.showImagePicker()
    }
}
