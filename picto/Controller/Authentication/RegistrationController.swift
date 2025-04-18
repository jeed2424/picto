////
////  RegistrationController.swift
////  InstagramFirestoreTutorial
////
////  Created by Stephen Dowless on 6/22/20.
////  Copyright © 2020 Stephan Dowless. All rights reserved.
////
//
//import UIKit
//
//class RegistrationController: UIViewController {
//    
//    // MARK: - Properties
//    
//    private var viewModel = RegistrationViewModel()
//    private var profileImage: UIImage?
//    weak var delegate: AuthenticationDelegate?
//    
//    private let plushPhotoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
//        button.tintColor = .white
//        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
//        return button
//    }()
//    
//    private let emailTextField: CustomTextField = {
//        let tf = CustomTextField(placeholder: "Email", imageName: "envelope")
//        tf.keyboardType = .emailAddress
//        return tf
//    }()
//    
//    private let passwordTextField: UITextField = {
//        let tf = CustomTextField(placeholder: "Password", imageName: "lock")
//        tf.isSecureTextEntry = true
//        return tf
//    }()
//    
//    private let fullnameTextField = CustomTextField(placeholder: "Fullname", imageName: "person")
//    private let usernameTextField = CustomTextField(placeholder: "Username", imageName: "person")
//    
//    private let signUpButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Sign Up", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).withAlphaComponent(0.5)
//        button.layer.cornerRadius = 5
//        button.setHeight(50)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
//        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
//        button.isEnabled = false
//        return button
//    }()
//    
//    private let alreadyHaveAccountButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Log In")
//        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
//        return button
//    }()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureUI()
//        configureNotificationObservers()
//    }
//    
//    // MARK: - Actions
//    
//    @objc func handleSignUp() {
//        guard let email = emailTextField.text else { return }
//        guard let password = passwordTextField.text else { return }
//        guard let fullname = fullnameTextField.text else { return }
//        guard let username = usernameTextField.text?.lowercased() else { return }
//        guard let profileImage = self.profileImage else { return }
//        
//        let credentials = AuthCredentials(email: email, password: password,
//                                          fullname: fullname, username: username,
//                                          profileImage: profileImage)
//
//        AuthService.registerUser(withCredential: credentials) { error in
//            if let error = error {
//                print("DEBUG: Failed to register user \(error.localizedDescription)")
//                return
//            }
//            
//            self.delegate?.authenticationDidComplete()
//        }
//    }
//    
//    @objc func handleShowLogin() {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    @objc func textDidChange(sender: UITextField) {
//        if sender == emailTextField {
//            viewModel.email = sender.text
//        } else if sender == passwordTextField {
//            viewModel.password = sender.text
//        } else if sender == fullnameTextField {
//            viewModel.fullname = sender.text
//        } else {
//            viewModel.username = sender.text
//        }
//        
//        updateForm()
//    }
//    
//    @objc func handleProfilePhotoSelect() {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.allowsEditing = true
//        
//        present(picker, animated: true, completion: nil)
//    }
//    
//    // MARK: - Helpers
//    
//    func configureUI() {
//        view.backgroundColor = UIColor.black
//
//        view.addSubview(plushPhotoButton)
//        plushPhotoButton.centerX(inView: view)
//        plushPhotoButton.setDimensions(height: 140, width: 140)
//        plushPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
//        
//        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField,
//                                                   fullnameTextField, usernameTextField,
//                                                   signUpButton])
//        stack.axis = .vertical
//        stack.spacing = 20
//        
//        view.addSubview(stack)
//        stack.anchor(top: plushPhotoButton.bottomAnchor, left: view.leftAnchor,
//                     right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
//        
//        view.addSubview(alreadyHaveAccountButton)
//        alreadyHaveAccountButton.centerX(inView: view)
//        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
//    }
//    
//    func configureNotificationObservers() {
//        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
//        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
//        fullnameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
//        usernameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
//    }
//}
//
//// MARK: - FormViewModel
//
//extension RegistrationController: FormViewModel {
//    func updateForm() {
//        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
//        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
//        signUpButton.isEnabled = viewModel.formIsValid
//    }
//}
//
//// MARK: - UIImagePickerControllerDelegate
//
//extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        
//        guard let selectedImage = info[.editedImage] as? UIImage else { return }
//        profileImage = selectedImage
//        
//        plushPhotoButton.layer.cornerRadius = plushPhotoButton.frame.width / 2
//        plushPhotoButton.layer.masksToBounds = true
//        plushPhotoButton.layer.borderColor = UIColor.white.cgColor
//        plushPhotoButton.layer.borderWidth = 2
//        plushPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
//        
//        self.dismiss(animated: true, completion: nil)
//    }
//}
