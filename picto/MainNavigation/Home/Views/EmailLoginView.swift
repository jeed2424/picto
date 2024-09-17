import Foundation
import UIKit
import Combine
import Foil
import SkyFloatingLabelTextField
import SupabaseManager

class EmailLoginView: UIView {

    let auth = AuthenticationService.make()

    private lazy var vStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical

        stack.spacing = 50

        return stack
    }()

    private lazy var hStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center

        stack.spacing = 10

        return stack
    }()
    private lazy var btnExit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setImage(R.image.cancel()?.resize(CGSize(width: 20, height: 20)).tint(.label), for: .normal)

        button.addTarget(self, action: #selector(exitRegistration(_:)), for: .touchUpInside)

        return button
    }()

    private lazy var registerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: 16)

        label.text = "LogIn"

        return label
    }()

    private lazy var errorLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textAlignment = .center
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 0

        return label
    }()

    private lazy var emailField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.keyboardType = .emailAddress
        field.autocapitalizationType = .none
        field.textColor = .label

        field.placeholder = "Email"
        field.title = "Email address"
        field.errorColor = .systemRed

        field.addTarget(self, action: #selector(verifyEmail(_:)), for: .editingChanged)

        return field
    }()

    private lazy var passwordField: SkyFloatingLabelTextField = {
        let field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.isSecureTextEntry = true
        field.autocapitalizationType = .none
        field.textColor = .label

        field.placeholder = "Password"
        field.title = "Password"
        field.errorColor = .systemRed

        return field
    }()

//    private lazy var lblRemember: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Remember me"
//        label.textColor = .label
//
//        return label
//    }()

    private lazy var btnSubmit: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("Login", for: .normal)

        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .defined.cyan100()

        button.layer.cornerRadius = 4

        button.addTarget(self, action: #selector(submitRegistration(_:)), for: .touchUpInside)

        return button
    }()

//    let checkBox = CustomCheckBox(frame: CGRect(x: 0, y: 0, width: 17.5, height: 17.5))

    override init(frame: CGRect) {
        super.init(frame: .zero)
        hideKeyboard()
        setupViews()
        resetValues()
        registerNotifications()
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmailLoginView {
    func setupViews() {

        translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .backgroundColor

        addSubviews([
            btnExit,
            vStack,
//            hStack,
            btnSubmit
        ])

        NSLayoutConstraint.activate([
            btnExit.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            btnExit.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -150),
//            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            //            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -150),
//            hStack.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 50),
            //           hStack.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -75),
            btnSubmit.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 75),
            btnSubmit.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        vStack.addArrangedSubviews([
            registerLabel,
            errorLbl,
            emailField,
            passwordField
        ])

//        hStack.addArrangedSubviews([
//            checkBox,
//            lblRemember
//        ])

        NSLayoutConstraint.activate([
            btnSubmit.widthAnchor.constraint(equalToConstant: 150)
//            checkBox.widthAnchor.constraint(equalToConstant: 17.5),
//            checkBox.heightAnchor.constraint(equalToConstant: 17.5)
            //   btnRemember.heightAnchor.constraint(equalToConstant: 30)
        ])

//        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
//        checkBox.addGestureRecognizer(gesture)
    }
}

// MARK: - Functions
extension EmailLoginView {
    private func verifyInfo() -> Bool {
        if (emailField.errorMessage == "" && passwordField.text != "") {
            return true
        } else {
            return false
        }
    }

    private func resetValues() {
        errorLbl.text = ""
        emailField.text = ""
        emailField.errorMessage = ""
        passwordField.text = ""
        passwordField.errorMessage = ""
    }

    private func loginUser() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        //        auth.loginUserWithEmail(email: emailField.text!, password: passwordField.text!) { (response, u) in
        //            Timer.schedule(delay: 0.3) { (t) in
        //                switch response {
        //                case .Success:
        //                    guard let usr = u else { return }
        //                    self.auth.authenticationSuccess(user: usr)
        //                    if self.checkBox.isChecked {
        //                        UserDefaultHelper().savedUserID = usr.id
        //                    }
        //                    self.resetValues()
        //                    NotificationCenter.default.post(name: NotificationNames.didLogin, object: usr)
        //                case .Error:
        //                    self.errorLbl.text = "Error loging in, please try again later."
        //                case .InvalidCredentials:
        //                    self.errorLbl.text = "Invalid Credentials"
        //                }
        //
        //            }
        
        let manager = SupabaseAuthenticationManager.sharedInstance
                
        manager.authenticate(.email, .signin, AuthObject(email: email, password: password), completion: { response, user in
            switch response {
                
            case .success:
                guard let id = user?.id else { return }
                
                self.getActiveUser(completion: { bmUser in
                    if bmUser != nil {
                        NotificationCenter.default.post(name: NotificationNames.didLogin, object: bmUser)
                    } else {
                        print("Hello")
                    }
                })
                //                print("")
                //                let user = BMUser(id: id, username: "", firstName: firstName ?? "", lastName: lastName ?? "", email: email, bio: "", website: "", showFullName: false, avatar: "", posts: [])
                //                NotificationCenter.default.post(name: NotificationNames.willShowUsernameSelection, object: user)
            case .error:
                print("")
            }
        })
    }
    
    private func getActiveUser(completion: @escaping (BMUser?) -> ()) {
        let authManager = SupabaseAuthenticationManager.sharedInstance
        
        authManager.currentUser(completion: { [weak self] user in
            guard let self = self else { return }
            
            if let user = user {
                let databaseManager = SupabaseDatabaseManager.sharedInstance
                var posts: [BMPost]? = []
                
                let bmUser = BMUser(id: user.id, username: user.username, firstName: user.firstName, lastName: user.lastName, email: user.email, bio: user.bio, website: user.website, showFullName: user.showFullName, avatar: user.avatar, posts: [])
                
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now(), execute: {
                    databaseManager.fetchUserPosts(user: user.id, completion: { userPosts in
                        posts = userPosts?.compactMap({ post in BMPost(identifier: post.identifier,
                                                                       createdAt: post.createdAt?.dateAndTimeFromString(),
                                                                       user: bmUser,
                                                                       caption: post.caption,
                                                                       location: "",
                                                                       category: nil,
                                                                       commentCount: post.commentCount,
                                                                       likeCount: Int8(post.likes?.count ?? 0),
                                                                       comments: nil,
                                                                       medias: {
                            post.images?.compactMap({ image in BMPostMedia(imageUrl: image, videoUrl: nil) })
                        }()
                        )})
                    })
                    
                    if let posts = posts {
                        bmUser.posts = posts
                    }
                    
                    let auth = AuthenticationService.make()
                    auth.authenticationSuccess(user: bmUser)
                    ProfileService.sharedInstance.saveUser(user: bmUser)
                    
                    completion(bmUser)
                    
//                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
//                        self.presentMain(user: bmUser)
//                    })
                })
            } else {
                completion(nil)
            }
        })
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        print("registered notifs")
    }
}

// MARK: - Actions
extension EmailLoginView {

    @objc func submitRegistration(_ sender: UIButton) {
        if verifyInfo() {
            errorLbl.text = ""
            loginUser()
            print("successfully logged in")
        } else {
            errorLbl.text = "Oops! Something went wrong! Please verify your information"
            print("Fix your mistakes")
        }
    }

    @objc func exitRegistration(_ sender: UIButton) {
        resetValues()
        NotificationCenter.default.post(name: NotificationNames.dismissViewToHome, object: nil)
    }

    @objc func verifyEmail(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textfield as? SkyFloatingLabelTextField {
                if(text.count < 3 || !text.contains("@")) {
                    floatingLabelTextField.errorMessage = "Invalid email"
                } else if !text.contains(".") {
                    floatingLabelTextField.errorMessage = "Invalid email"
                } else {
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }

//    @objc func didTapCheckbox() {
//        checkBox.toggle()
//    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.frame.origin.y == 0 {
                self.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if self.frame.origin.y != 0 {
            self.frame.origin.y = 0
        }
    }
}
