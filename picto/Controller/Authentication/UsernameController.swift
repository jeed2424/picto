////
////  UsernameController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 2/9/21.
////  Copyright © 2021 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//
//class UsernameController: UIViewController {
//    
//    // MARK: - Properties
//    
//    weak var delegate: AuthenticationDelegate?
//    private let uid: String
//    
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Choose A Username"
//        label.textColor = .white
//        label.font = UIFont.systemFont(ofSize: 26)
//        return label
//    }()
//    
//    private let infoLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Pick a username for your account. You can always change it later"
//        label.textColor = .lightGray
//        label.font = UIFont.systemFont(ofSize: 14)
//        label.numberOfLines = 2
//        label.textAlignment = .center
//        return label
//    }()
//    
//    private lazy var usernameTextField: CustomTextField = {
//        let tf = CustomTextField(placeholder: "Username...", imageName: "person")
//        tf.clearButtonMode = .whileEditing
//        tf.autocapitalizationType = .none
//        tf.delegate = self
//        return tf
//    }()
//    
//    private let signupButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Sign Up", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = UIColor.systemBlue
//        button.layer.cornerRadius = 5
//        button.setHeight(50)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
//        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
//        return button
//    }()
//    
//    private let errorLabel: UILabel = {
//        let label = UILabel()
//        label.text = "This username is not available"
//        label.textColor = .red
//        label.font = UIFont.systemFont(ofSize: 14)
//        return label
//    }()
//    
//    // MARK: - Lifecycle
//    
//    init(uid: String) {
//        self.uid = uid
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        configureUI()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.isHidden = true
//    }
//    
//    // MARK: - Helpers
//    
//    func configureUI() {
//        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
//
//        view.addSubview(titleLabel)
//        titleLabel.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 24)
//        
//        view.addSubview(infoLabel)
//        infoLabel.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
//                         paddingTop: 24, paddingLeft: 32, paddingRight: 32)
//        
//        view.addSubview(usernameTextField)
//        usernameTextField.anchor(top: infoLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
//                                 paddingTop: 32, paddingLeft: 32, paddingRight: 32)
//        
//        view.addSubview(errorLabel)
//        errorLabel.anchor(top: usernameTextField.bottomAnchor, left: usernameTextField.leftAnchor, paddingTop: 8, paddingLeft: 4)
//        errorLabel.isHidden = true
//
//        
//        view.addSubview(signupButton)
//        signupButton.anchor(top: usernameTextField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
//                                 paddingTop: 48, paddingLeft: 32, paddingRight: 32)
//    }
//    
//    func showErrorMessage(_ show: Bool) {
//        errorLabel.isHidden = !show
//        usernameTextField.layer.borderColor = show ? UIColor.red.cgColor : nil
//        usernameTextField.layer.borderWidth = show ? 1.0 : 0.0
//    }
//    
//    // MARK: - Actions
//    
//    @objc func handleSignUp() {
//        guard let username = usernameTextField.text?.lowercased() else { return }
//        self.showLoader(true)
//        
//        AuthService.validateUsername(username) { isValid in
//            self.showLoader(false)
//            
//            if isValid {
//                self.uploadUsername(username)
//            } else {
//                self.showErrorMessage(true)
//            }
//        }
//    }
//    
//    // MARK: - API
//    
//    func uploadUsername(_ username: String) {
//        self.showLoader(true)
//        AuthService.uploadUsername(username, toUid: uid) { _ in
//            self.showLoader(false)
//            self.delegate?.authenticationDidComplete()
//        }
//    }
//}
//
////
//
//extension UsernameController: UITextFieldDelegate {
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        self.showErrorMessage(false)
//        return true
//    }
//}
//
//
